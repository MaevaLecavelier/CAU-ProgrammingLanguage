#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"
extern int spaceNumber;
extern int tabNumber;
extern int lineNumber;
extern void yyerror();

/* current scope */
int cur_scope = 0;

void init_hash_table(){
	int i;
	hash_table = malloc(SIZE * sizeof(list_t*));
	for(i = 0; i < SIZE; i++) hash_table[i] = NULL;
}

unsigned int hash(char *key){
	unsigned int hashval = 0;
	for(;*key!='\0';key++) hashval += *key;
	hashval += key[0] % 11 + (key[0] << 3) - key[0];
	return hashval % SIZE;
}

void insert(char *name, int len, int type, int inf_type, int lineNumber){
	unsigned int hashval = hash(name);
	list_t *l = hash_table[hashval];

	while ((l != NULL) && (strcmp(name,l->st_name) != 0)) l = l->next;

	/* variable not yet in table */
	if (l == NULL){

		l = (list_t*) malloc(sizeof(list_t));
		strncpy(l->st_name, name, len);
		/* add to hashtable */
		l->st_type = type;
		l->inf_type = inf_type;
		l->scope = cur_scope;
		l->lines = (RefList*) malloc(sizeof(RefList));
		l->lines->lineNumber = lineNumber;
		l->lines->next = NULL;
		l->next = hash_table[hashval];
		hash_table[hashval] = l;
		if(l->st_type == UNDEF) {
			fprintf(stderr,"Error - Undefined variable: %s at line %d \n", l->st_name, l->lines->lineNumber);
			exit(1);
		}
		else printf("Inserted %s for the first time with line number %d!\n", name, lineNumber); // error checking
	}
	/* found in table, so just add line number */
	else{
		l->scope = cur_scope;
		RefList *t = l->lines;
		while (t->next != NULL) t = t->next;
		/* add linenumber to reference list */
		t->next = (RefList*) malloc(sizeof(RefList));
		t->next->lineNumber = lineNumber;
		t->next->next = NULL;
		printf("Found %s again at line %d!\n", name, lineNumber);
	}
}

list_t *lookup(char *name){ /* return symbol if found or NULL if not found */
	unsigned int hashval = hash(name);
	list_t *l = hash_table[hashval];
	while ((l != NULL) && (strcmp(name,l->st_name) != 0)) l = l->next;
	return l; // NULL is not found
}

list_t *lookup_scope(char *name, int scope){ /* return symbol if found or NULL if not found */
	unsigned int hashval = hash(name);
	list_t *l = hash_table[hashval];
	while ((l != NULL) && (strcmp(name,l->st_name) != 0) && (scope != l->scope)) l = l->next;
	return l; // NULL is not found
}

void hide_scope(){ /* hide the current scope */
	if(cur_scope > 0) cur_scope--;
}

void incr_scope(){ /* go to next scope */
	cur_scope++;
}

/* print to stdout by default */
void symtab_dump(FILE * of){
  int i;
	fprintf(of, "\n\n");
	fprintf(of, "Information about the variables: \n\n");
  fprintf(of,"----------   ---------- \t------------------------------------\n");
  fprintf(of,"   Name         Type   	\t        Appeared on line number\n");
  fprintf(of,"----------   ---------- \t------------------------------------\n");
  for (i=0; i < SIZE; ++i){
		if (hash_table[i] != NULL){
			list_t *l = hash_table[i];
			while (l != NULL){
				RefList *t = l->lines;
				fprintf(of,"%-12s ",l->st_name);
				if (l->st_type == INT_TYPE) fprintf(of,"%-7s","int \t");
				else if (l->st_type == REAL_TYPE) fprintf(of,"%-7s","float\t");
				else if (l->st_type == ARRAY_TYPE){
					fprintf(of,"array of ");
					if (l->inf_type == INT_TYPE) 		   fprintf(of,"%-7s","int");
					else if (l->inf_type  == REAL_TYPE)    fprintf(of,"%-7s","float");
					else fprintf(of,"%-7s","undef");
				}
				else if (l->st_type == FUNCTION_TYPE) fprintf(of,"%-7s","function\t");
				else if (l->st_type == MAINPROG_TYPE) fprintf(of,"%-7s","mainprog\t");
				else fprintf(of, "%-7s", "undef");
				while (t != NULL){
					fprintf(of,"\t%4d ",t->lineNumber);
					t = t->next;
				}
				fprintf(of,"\n");
				l = l->next;
			}
    }
  }
	fprintf(of, "\n\n");
	fprintf(of, "Number of lines: %d\n", lineNumber);
	fprintf(of, "Number of spaces: %d\n", spaceNumber);
	fprintf(of, "Number of tabulation: %d\n", tabNumber);

}
