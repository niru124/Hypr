-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Compat shim: Neovim >= 0.11 changed `Query:iter_matches()` so each capture id
-- maps to a *list* of nodes (`match[id] = { node1, ... }`) instead of a single
-- node. The legacy nvim-treesitter (master branch) pinned by AstroNvim v4 still
-- expects single nodes, so any `#make-range!` textobject query (python
-- `@call.inner`/`@parameter.outer`, cpp, c, bash, ...) crashed with:
--   tsrange.lua:27: attempt to call method 'start' (a nil value)
-- Unwrap single captures here so select/move/swap keep working.
-- (Long-term fix is migrating to AstroNvim v5 + new nvim-treesitter.)
do
  local ok, ts_query = pcall(require, "nvim-treesitter.query")
  if ok and ts_query and ts_query.iter_prepared_matches then
    local tsrange = require "nvim-treesitter.tsrange"

    -- Return the single node when given a legacy single node, the first node
    -- of a new-style node list, or nil for missing/empty captures (callers
    -- already tolerate nil for optional captures like `(_)? @_end`).
    local function as_first(v)
      if type(v) == "table" and type(v.start) ~= "function" then
        return v[1]
      end
      return v
    end

    -- Same, but last node (used for the *end* of a `#make-range!` range).
    local function as_last(v)
      if type(v) == "table" and type(v.start) ~= "function" then
        return v[#v]
      end
      return v
    end

    local function split(to_split)
      local t = {}
      for str in string.gmatch(to_split, "([^.]+)") do
        table.insert(t, str)
      end
      return t
    end

    -- Same as the legacy `iter_prepared_matches`, but unwraps new-style
    -- node lists before building prepared matches and `#make-range!` ranges.
    function ts_query.iter_prepared_matches(query, qnode, bufnr, start_row, end_row)
      local matches = query:iter_matches(qnode, bufnr, start_row, end_row, { all = false })

      local function iterator()
        local pattern, match, metadata = matches()
        if pattern ~= nil then
          local prepared_match = {}

          for id, nodes in pairs(match) do
            local name = query.captures[id]
            if name ~= nil then
              local path = split(name .. ".node")
              ts_query.insert_to_path(prepared_match, path, as_first(nodes))
              local metadata_path = split(name .. ".metadata")
              ts_query.insert_to_path(prepared_match, metadata_path, metadata[id])
            end
          end

          local preds = query.info.patterns[pattern]
          if preds then
            for _, pred in pairs(preds) do
              if pred[1] == "set!" and type(pred[2]) == "string" then
                ts_query.insert_to_path(prepared_match, split(pred[2]), pred[3])
              end
              if pred[1] == "make-range!" and type(pred[2]) == "string" and #pred == 4 then
                ts_query.insert_to_path(
                  prepared_match,
                  split(pred[2] .. ".node"),
                  tsrange.TSRange.from_nodes(bufnr, as_first(match[pred[3]]), as_last(match[pred[4]]))
                )
              end
            end
          end

          return prepared_match
        end
      end
      return iterator
    end

    -- `iter_captures` has the same shape change; restore the single-node
    -- contract for its (legacy) consumers.
    local orig_iter_captures = ts_query.iter_captures
    function ts_query.iter_captures(bufnr, query_name, root, lang)
      local iter = orig_iter_captures(bufnr, query_name, root, lang)
      return function()
        local name, node, metadata = iter()
        if name == nil then
          return
        end
        return name, as_first(node), metadata
      end
    end
  end
end
