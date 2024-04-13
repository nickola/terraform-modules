# Not to print any recipes before executing them
.SILENT:

# Default target (linting)
all:
	for directory in */; do echo "Module \"$$directory\""; cd "$$directory"; terraform fmt -recursive -diff -write=false; cd ..; done
