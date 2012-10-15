# Translation Guide

There is an effort to translate KnightOS into various languages. Language files can
be found in /lang/<language code>/. You can build KnightOS to target a particular
language by running "build --language \[language code]". The default, if not specified,
is "en_us". The current list of locales supported is:

* English (US)
* French

If you wish to contribute, fork KnightOS and modify the language files for the language you
wish to contribute to. You should create a pull reqeust every so often to add more content
in the language you are working on. Be sure to follow the generic coding style guidelines.
All code and comments must remain in English, only user-visible text should be translated.
File names should not be changed. Grammar and spelling are of upmost importance, make sure
that you get this right.

If you wish to start a new language, copy all the files from en_us to another folder and
begin translating.

Do not use Google Translate. You should not participate in a translation effort
if you are not profecient in the language you are translating.

## Technical Details

When provided --language when built, the build tool adds /lang/\<language>/ to the include
path. From assembly, you simply \#include "file.lang" and the correct one for the target
language will be included. Additionally, "lang_\<language>" will be globally defined, which
is useful for places where locale affects code, such as getting the time or date as a string.

For example, when "en_us" is the target language, "lang/en_us/" will be added to the include
path, and "lang_en_us" will be globally defined.