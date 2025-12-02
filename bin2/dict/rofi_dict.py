#!/usr/bin/env python3

import sys
import json
import urllib.request

def search_word(word):
    api_url = f"https://api.dictionaryapi.dev/api/v2/entries/en/{word}"
    try:
        with urllib.request.urlopen(api_url) as url:
            data = json.loads(url.read().decode())
            return data
    except Exception as e:
        return [{"error": f"Could not fetch definition: {e}"}]

def format_output(data):
    if not data or "error" in data[0]:
        return f"Error: {data[0].get('error', 'No definition found.')}"

    output_lines = []
    for entry in data:
        word = entry.get("word", "N/A")
        phonetic = entry.get("phonetic", "N/A")
        
        output_lines.append(f"Word: {word}")
        output_lines.append(f"Phonetic: {phonetic}")

        for meaning in entry.get("meanings", []):
            part_of_speech = meaning.get("partOfSpeech", "N/A")
            output_lines.append(f"  Part of Speech: {part_of_speech}")
            for definition_obj in meaning.get("definitions", []):
                definition = definition_obj.get("definition", "N/A")
                output_lines.append(f"    Definition: {definition}")
        output_lines.append("-" * 30) # Separator for multiple entries/meanings
    return "\n".join(output_lines)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        word_to_search = sys.argv[1]
    else:
        # If no argument is provided, read from stdin (for Rofi)
        word_to_search = sys.stdin.readline().strip()

    if word_to_search:
        result = search_word(word_to_search)
        print(format_output(result))
    else:
        print("Please enter a word to search.")
