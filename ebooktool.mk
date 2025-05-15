SHELL		::= /bin/bash
PANDOC		::= pandoc
PANDOCFLAGS	::= --number-sections --toc --pdf-engine=lualatex
GHOSTSCRIPT	::= gs
GHOSTSCRIPTFLAGS::= -q -dPDFX -sColorConversionStrategy=CMYK

outputs 	::= $(foreach cover,$(covers),$($(cover))Cover.pdf) \
		    $(foreach book,$(books),$($(book)).pdf $($(book)).epub $($(book)).docx $($(book)).odt)
fromfolder 	= $(sort $(wildcard $1/*))
contents	= $(call fromfolder,chapters/$1) $(call fromfolder,back)
filters		= $(call fromfolder,$(EBOOKTOOL)/filters)
filters-args	= $(foreach f,$(filters),--lua-filter=$f)
format-inputs	= $(foreach f,$(filter %.yaml,$1),--metadata-file=$f) $(filter %.md,$1)

all: $(books)
covers: $(foreach cover,$(covers),$($(cover))Cover.pdf)
epub: $(foreach book,$(books),$($(book)).epub)
pdf: $(foreach book,$(books),$($(book)).pdf)
docx: $(foreach book,$(books),$($(book)).docx)
odt: $(foreach book,$(books),$($(book)).odt)
clean:
	rm -f $(outputs)

define book_rules
$1: $(if $(wildcard covers/$1.ps),$($1)Cover.pdf) $($1).pdf $($1).epub $($1).docx $($1).odt
$($1)Cover.pdf: covers/$1.ps covers/$1.cover.jpg
$($1).epub: metadata/$1.yaml metadata/$1.epub.yaml $$(call contents,$1) $(wildcard covers/$1.epub.jpg) $(wildcard style/$1.css)
$($1).pdf: metadata/$1.yaml $$(call contents,$1)
$($1).docx: metadata/$1.yaml $$(call contents,$1)
$($1).odt: metadata/$1.yaml $$(call contents,$1)
endef
$(foreach book,$(books),$(eval $(call book_rules,$(book))))

%Cover.pdf: $(EBOOKTOOL)/covers/conf.ps $(EBOOKTOOL)/covers/lib.ps
	$(GHOSTSCRIPT) $(GHOSTSCRIPTFLAGS) -dBATCH -dNOPAUSE -dSAFER -sDEVICE=pdfwrite \
		$(foreach f,$(filter-out %.ps,$^),--permit-file-read=$f) \
		-sOUTPUTFILE=$@ $(filter %.ps,$^)

%.epub: $(EBOOKTOOL)/style/epub.xml $(EBOOKTOOL)/metadata/epub.yaml $(EBOOKTOOL)/style/epub.css $(filters)
	$(PANDOC) $(PANDOCFLAGS) \
		-t epub --template $(filter %.xml,$^) \
		-o $@ \
		$(filters-args) \
		--css <(cat $(filter %.css,$^)) \
		--epub-cover-image $(filter %.epub.jpg,$^) \
		$(call format-inputs,$^)

%.pdf: $(EBOOKTOOL)/metadata/pdf.yaml $(filters)
	$(PANDOC) $(PANDOCFLAGS) -t latex -o $@ $(filters-args) $(call format-inputs,$^)

%.docx: $(filters)
	$(PANDOC) $(PANDOCFLAGS) -t docx -o $@ $(filters-args) $(call format-inputs,$^)

%.odt: $(filters)
	$(PANDOC) $(PANDOCFLAGS) -t odt -o $@ $(filters-args) $(call format-inputs,$^)

.PHONY: all covers epub pdf docx odt clean $(books)
