local ls = require "luasnip"
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s(
    "main",
    fmt(
      [[
#include <iostream>
using namespace std;

int main() {{
    {}
    return 0;
}}
]],
      { i(1) }
    )
  ),
}
