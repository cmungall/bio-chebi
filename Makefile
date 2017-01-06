OBO = http://purl.obolibrary.org/obo
GODIR = $(HOME)/repos/go/ontology
GOX = $(GODIR)/extensions

HAS_CHEM_ROLE = RO:0002262
HAS_APP_ROLE = RO:0002261
HAS_BIO_ROLE = RO:0002260
HAS_ROLE = RO:0000087

all: substance-with-role.obo substance-with-role.owl
test: all
clean:
	test -f role.obo && rm role.obo
	test -f chebi.obo && rm chebi.obo

seed: bio-chebi.owl

# TODO
bio-chebi.owl: chebi.obo
	owltools --create-biochebi -o $@ -c $<

# TODO: trigger
chebi.obo:
	wget $(OBO)/chebi.obo
.PRECIOUS: chebi.obo

chebi.owl: chebi.obo
	robot convert -i $< -o $@

chebi.ttl: chebi.obo
	robot convert -i $< -o $@

role.obo: chebi.obo
	owltools $< --reasoner-query -r elk -d CHEBI:50906 --make-ontology-from-results $(OBO)/go/chebi/role.owl -o -f obo $@

substance-with-role.obo: role.obo
	./util/make-substance-by-role.pl -s 'role' -r $(HAS_ROLE) $< > $@.tmp && mv $@.tmp $@

substance-with-role.owl: substance-with-role.obo
	robot convert -i $< -o $@
