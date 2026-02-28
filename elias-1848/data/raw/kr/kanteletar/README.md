# Kanteletar

This directory contains a version of Kanteletar obtained from Project Gutenberg,
with some manual corrections. The original text file was converted to
the following files:
- `kanteletar.xml` - containing text and metadata in SKVR format,
- `categories.csv` - containing the hierarchy of categories (chapters),
- `poem_category.csv` - containing an assignment of poems to categories.

The column `type_is_minor` in the file `poem_category.csv` is added for
compatibility with other files used in the FILTER project. Here it's
always set to `0`.
