-- Deploy entry_type_label
-- requires: arbschema
-- requires: arbroles
-- requires: entry_type
-- requires: language

BEGIN;

CREATE TABLE arb.entry_type_label (
       entry_type varchar(20) not null references arb.entry_type,
       language varchar not null references arb.language,
       label text not null,
       description text,
       UNIQUE (entry_type, language));

INSERT INTO arb.entry_type_label
       (language, entry_type, label, description) VALUES

('en', 'article', 'Article in a Journal or Newspaper', 'An article in a journal, magazine, newspaper, or other periodical which forms a self-contained unit with its own title. The title of the periodical is given in the journaltitle field. If the issue has its own title in addition to the main title of the periodical, it goes in the issuetitle field. Note that editor and related fields refer to the journal while translator and related fields refer to the article.'),

('en', 'book', 'Book', 'A single-volume book with one or more authors where the authors share credit for the work as a whole. This entry type also covers the function of the @inbook type of traditional BibTeX.'),

('en', 'mvbook', 'Multi Volume Book', 'A multi-volume @book. For backwards compatibility, multi-volume books are also supported by the entry type @book. However, it is advisable to make use of the dedicated entry type @mvbook.'),

('en', 'inbook', 'In Book', 'A part of a book which forms a self-contained unit with its own title. Note that the profile of this entry type is different from standard BibTeX'),

('en', 'bookinbook', 'Book in Book', 'This type is similar to @inbook but intended for works originally published as a stand-alone book. A typical example are books reprinted in the collected works of an author'),

('en', 'suppbook', 'Supp. Material in a Book', 'Supplemental material in a @book. This type is closely related to the @inbook entry type. While @inbook is primarily intended for a part of a book with its own title (e. g., a single essay in a collection of essays by the same author), this type is provided for elements such as prefaces, introductions, forewords, afterwords, etc.  which often have a generic title only. Style guides may require such items to be formatted differently from other @inbook items. The standard styles will treat this entry type as an alias for @inbook.'),

('en', 'booklet', 'Booklet', 'A book-like work without a formal publisher or sponsoring institution. Use the field howpublished to supply publishing information in free format, if applicable. The field type may be useful as well.'),

('en', 'collection', 'Collection of Essays', 'A single-volume collection with multiple, self-contained contributions by distinct authors which have their own title. The work as a whole has no overall author but it will usually have an editor.'),

('en', 'mvcollection', 'Multi Volume Collection of Essays', 'A multi-volume @collection. For backwards compatibility, multi-volume collec- tions are also supported by the entry type @collection. However, it is advisable to make use of the dedicated entry type @mvcollection.'),

('en', 'incollection', 'Essay in a Collection', 'A contribution to a collection which forms a self-contained unit with a distinct author and title. The author refers to the title, the editor to the booktitle, i. e., the title of the collection.'),

('en', 'suppcollection', 'Supp. Material in a Collection', 'Supplemental material in a @collection. This type is similar to @suppbook but related to the @collection entry type. The standard styles will treat this entry type as an alias for @incollection.'),

('en', 'manual', 'Manual', 'Technical or other documentation, not necessarily in printed form.'),

('en', 'misc', 'Miscellangelus', 'A fallback type for entries which do not
fit into any other category. Use the field howpublished to supply
publishing information in free format, if applicable. The field type
may be useful as well.'),

('en', 'online', 'Online', 'An online resource. author, editor, and year are omissible in terms of § 2.3.2.  This entry type is intended for sources such as web sites which are intrinsically online resources. Note that all entry types support the url field. For example, when adding an article from an online journal, it may be preferable to use the @article type and its url field.'),

('en', 'patent', 'Patent', 'A patent or patent request. The number or record token is given in the number field. Use the type field to specify the type and the location field to indicate the scope of the patent, if different from the scope implied by the type.'),

('en', 'periodical', 'Periodical', 'An complete issue of a periodical, such as a special issue of a journal. The title of the periodical is given in the title field. If the issue has its own title in addition to the main title of the periodical, it goes in the issuetitle field.'),

('en', 'suppperiodical', 'Supp. Matrial in a Periodical', 'Supplemental material in a @periodical. This type is similar to @suppbook but related to the @periodical entry type. The role of this entry type may be more obvious if you bear in mind that the @article type could also be called @inperiodical. This type may be useful when referring to items such as regular columns, obituaries, letters to the editor, etc. which only have a generic title. Style guides may require such items to be formatted differently from articles in the strict sense of the word. The standard styles will treat this entry type as an alias for @article.'),

('en', 'procedings', 'Procedings', 'A single-volume conference proceedings. This type is very similar to @collection.  It supports an optional organization field which holds the sponsoring institution.'),

('en', 'mvprocedings', 'Multi Volume Procedings', 'A multi-volume @proceedings entry. For backwards compatibility, multi-volume proceedings are also supported by the entry type @proceedings. However, it is advisable to make use of the dedicated entry type @mvproceedings.'),

('en', 'inprocedings', 'Article in Conference Procedings', 'An article in a conference proceedings. This type is similar to @incollection. It supports an optional organization field.'),

('en', 'reference', 'Reference', 'A single-volume work of reference such as an encyclopedia or a dictionary. This is a more specific variant of the generic @collection entry type. The standard styles will treat this entry type as an alias for @collection.'),

('en', 'mvreference', 'Multi-Volume Reference', 'A multi-volume @reference entry. The standard styles will treat this entry type as an alias for @mvcollection. For backwards compatibility, multi-volume refer- ences are also supported by the entry type @reference. However, it is advisable to make use of the dedicated entry type @mvreference.'),

('en', 'inreference', 'Article in Reference', 'An article in a work of reference. This is a more specific variant of the generic @incollection entry type. The standard styles will treat this entry type as an alias for @incollection.'),

('en', 'report', 'Report', 'A technical report, research report, or white paper published by a university or some other institution. Use the type field to specify the type of report. The sponsoring institution goes in the institution field.'),

('en', 'set', 'Set', 'An entry set. This entry type is special.'),

('en', 'thesis', 'Thesis', 'A thesis written for an educational institution to satisfy the requirements for a degree.  Use the type field to specify the type of thesis.'),

('en', 'unpublished', 'Unpublished', 'A work with an author and a title which has not been formally published, such as a manuscript or the script of a talk. Use the fields howpublished and note to supply additional information in free format, if applicable.'),

('en', 'xdata', 'xdata', 'This entry type is special. @xdata entries hold data which may be inherited by other entries using the xdata field. Entries of this type only serve as data containers; they may not be cited or added to the bibliography.');


COMMIT;
