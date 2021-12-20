# Translations

You can found found the list of locale code here : [List of country locale code](https://saimana.com/list-of-country-locale-code/)

## New Translations

1. Fill out [`template.pot`](template.pot) with your translations then open a [new issue](https://github.com/orblazer/plasma-applet-resources-monitor/issues/new), name the file `spanish.txt`, attach the txt file to the issue (drag and drop).

Or if you know how to make a pull request

1. Copy the `template.pot` file and name it your locale's code (Eg: `en`/`de`/`fr`) with the extension `.po`. Then fill out all the `msgstr ""`.
2. Build the translation with `npm run i18n:build`
3. Test the translation with `LANGUAGE="country_CODE:locale" LANG="country_CODE.UTF-8" npm run dev`

  **Note** : You need install language pack first.

## Scripts

* `npm run i18:merge` will parse the `i18n()` calls in the `*.qml` files and write it to the `template.pot` file. Then it will merge any changes into the `*.po` language files.
* `npm run i18n:build` will convert the `*.po` files to it's binary `*.mo` version and move it to `contents/locale/...` which will bundle the translations in the `*.plasmoid` without needing the user to manually install them.

## Status

|  Locale  |  Lines  | % Done|
|----------|---------|-------|
| Template |      67 |       |
| fr       |   67/67 |  100% |
| nl       |   67/67 |  100% |
