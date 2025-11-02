# Translations

You can found found the list of locale code here : [List of country locale code](https://saimana.com/list-of-country-locale-code/)

## New Translations

1. Fill out the file [`template.pot`](template.pot) with your translation. This can be done with any
   text editor or a specialized application e.g. ["poedit"](https://poedit.net).
2. Open a [new issue](https://github.com/orblazer/plasma-applet-resources-monitor/issues/new),
   name the file e.g. `spanish.txt`, attach the txt file to the issue (drag and drop).

Or if you're able to work with "github's" mechanics and "npm":

1. Copy the `template.pot` file and name it your locale's code (Eg: `en`/`de`/`fr`) with the
   extension `.po`. Then fill out all the `msgstr ""`.
2. Add `Name` and `Description` translation to `../metadata.json`
3. Build the translation with `./scripts/translate-build.sh`
4. Test the translation with `./scripts/test.sh country_CODE` (or `LANGUAGE="country_CODE:locale" LANG="country_CODE.UTF-8" ./scripts/test.sh`)

   **Note** : You need install language pack first.

## Scripts

- `npm run i18:merge` (or `./scripts/translate-merge.sh`) will parse the `i18n()` calls in the `*.qml` files and write it to the
  `template.pot` file. Then it will merge any changes into the `*.po` language files.
- `npm run i18n:build` (or `./scripts/translate-build.sh`) will convert the `*.po` files to it's binary `*.mo` version and move it
  to `contents/locale/...` which will bundle the translations in the `*.plasmoid` without needing
  the user to manually install them.

## Status

|  Locale  |  Lines  | % Done|
|----------|---------|-------|
| Template |     146 |       |
| de       | 127/146 |   86% |
| fr       | 146/146 |  100% |
| nl       | 127/146 |   86% |
