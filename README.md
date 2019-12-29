# Text-based flashcards

This is a small text-based flashcards utility.
It reads the vocabulary from a markdown file and allows
show words from the vocabulary, do quiz and show most mistaken words in quiz.

## Installation

### From binary

Pre-compiled binary for Linux is available from the [releases page](https://github.com/danhper/flashcards-cli/releases).
Simply download the binary, put it somewhere in your path and make it executable.

```
wget https://github.com/danhper/flashcards-cli/releases/download/v0.2.0/flashcards-cli -O /usr/local/bin/flashcards
chmod +x /usr/local/bin/flashcards
```

I am too lazy to get the release working for macOS but help would be more than welcome.

### From source

Compiling from source requires a not too old version of ocaml (I am using 4.07.1 but think anything above 4.02 should work) and [opam](https://github.com/ocaml/opam).

```
git clone https://github.com/danhper/flashcards-cli.git
cd flashcards-cli
opam install -w .
```
## Vocabulary file format

This tool requires a vocabulary file to read from. The format is very simple,
it is a markdown file containing a table in the following format.

```
Word      | Translation | Notes
----------|-------------|----------------
die Tasse | cup         | plural: Tassen
klein     | small       |
```

The header is ignored and the third column is optional. The only requirement
is to have a table with at least two columns.
I do not mind supporting other formats if someone is willing to send a PR.

## Usage

The executable should be available as `flashcards`.

NOTE: By default, flashcards configuration and other related files will be saved
in `~/.flashcards`. This can be changed by setting the `FLASHCARDS_HOME` environment variable to point to any directory.

The first thing is to set the path for the vocabulary path with `flashcards init`.
The tool does not understand `~` or `$HOME` so please use the absolute path of the file.

Then, a couple of commands can be useful:

* `flashcards show -random` - shows a random word from the vocabulary
* `flashcards quiz guess-word` - starts a quiz to guess the original word
* `flashcards quiz guess-translation` - starts a quiz to guess the translation
* `flashcards top-n -n 10` - show the top 10 missed words during the quiz


### Word search

The tool `search` command can search for a word using a pre-configured URL.
For example, to set the German Wiktionary as a search tool, the following can be added to the tool configuration (`~/.flashcards/config.json` by default).

```
{
  "vocabulary_path": "/path/to/vocabulary",
  "search_url": "https://de.wiktionary.org/wiki/$word"
}
```

`$word` will be replaced by the keyword passed to the `search` command, for example

```
flashcard search Kaffee
```

## How I use the tool

I am currently experimenting this to learn German.
This is what I am trying out

1. Study normally (this is the important part, unrelated to this repository)
2. Write down the words I learn in a markdown table
3. Use this tool `quiz` to revise the vocabulary
4. Use this tool to show a random word on each new terminal

When sampling a random word, most recent word have a higher probability to show up than older words (old here simply means before in the markdown file) and mistaken words during the quiz have an even higher probability.

To show a random word each time a new terminal is spawned, adding something as follow in `~/.bashrc` or `~/.zshrc` should do the job.

```bash
if command -v flashcards > /dev/null 2>&1
    flashcards show -random
end
```

## Exporting to AnkiApp

It is quite useful to be able to practice on a phone, I am currently trying
[Ankiapp](https://www.ankiapp.com/) for that.

The CLI has a command to export to CSV, which can then be imported to
AnkiApp using their [wep app](https://api.ankiapp.com/nexus/)

The following command worked well enough for my needs:

```
flashcards export -no-headers -merge-notes -merge-with "<br>" vocab.csv
```

## Random word sampling

The weights are computed as follow:

1. If a word is wrong during the quiz, multiply current weight by 5 (not going above 10000)
2. If a word is right during the quiz, divide current weight by 5 (not going below 1)
3. If the word has never been seen in the quiz, use a weight of 1
4. Increase the weight by 1 for each row (i.e. if not seen in quiz, the word on the 20th row will be twice more likely to show up than the word on the 10th row)

The random word (both for the quiz and the show command) is then sampled using a non-uniform probability distribution based on these weights.
