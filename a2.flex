%{
#define RWORD   0
#define SSYMBOL 1
#define OTOKEN  2
#define ERR     3
#define CERR    4

int tokenCat;
int lineno = 1;

FILE * source;

typedef enum{
    /* Reserved Words */
    BOOL, IF, INT, ELSE, NOT, RETURN, TRUE, FALSE, VOID, WHILE, 
    
    /* Special Symbols */
    PLUS, MINUS, STAR, SLASH, 
    LEFT, LEFT_EQUAL, RIGHT, RIGHT_EQUAL,
    EQUAL_EQUAL, EXCLAMATION_MARK_EQUAL, EQUAL,
    AND_AND, OR_OR,
    SEMICOLON, COMMA, LEFT_CIRCLE_BRACKET, RIGHT_CIRCLE_BRACKET,
    LEFT_SQUARE_BRACKET, RIGHT_SQUARE_BRACKET,
    LEFT_CURLY_BRACKET, RIGHT_CURLY_BRACKET,
    SLASH_STAR, STAR_SLASH,

    /* Other Tokens */
    ID, NUM, 

    /* Book-Keeping */
    END, ERROR, COMMENT_ERROR
} TokenType;

void printToken(const char* lexeme);
%}

digit       [0-9]
letter      [a-zA-Z]
id          {letter}+{letter}*
num         {digit}+{digit}*
newline     \n
whitespace  [ \t]+
comment     "/*".*"*/"
commentError "/*".*

%%

"bool"        {tokenCat = RWORD; return BOOL;}
"if"          {tokenCat = RWORD; return IF;}
"int"         {tokenCat = RWORD; return INT;}
"else"        {tokenCat = RWORD; return ELSE;}
"not"         {tokenCat = RWORD; return NOT;}
"return"      {tokenCat = RWORD; return RETURN;}
"true"        {tokenCat = RWORD; return TRUE;}
"false"       {tokenCat = RWORD; return FALSE;}
"void"        {tokenCat = RWORD; return VOID;}
"while"       {tokenCat = RWORD; return WHILE;}

"+"           {tokenCat = SSYMBOL; return PLUS;}
"-"           {tokenCat = SSYMBOL; return MINUS;}
"*"           {tokenCat = SSYMBOL; return STAR;}
"/"           {tokenCat = SSYMBOL; return SLASH;}
"<"           {tokenCat = SSYMBOL; return LEFT;}
"<="          {tokenCat = SSYMBOL; return LEFT_EQUAL;}
">"           {tokenCat = SSYMBOL; return RIGHT;}
">="          {tokenCat = SSYMBOL; return RIGHT_EQUAL;}
"=="          {tokenCat = SSYMBOL; return EQUAL_EQUAL;}
"!="          {tokenCat = SSYMBOL; return EXCLAMATION_MARK_EQUAL;}
"="           {tokenCat = SSYMBOL; return EQUAL;}
"&&"          {tokenCat = SSYMBOL; return AND_AND;}
"||"          {tokenCat = SSYMBOL; return OR_OR;}
";"           {tokenCat = SSYMBOL; return SEMICOLON;}
","           {tokenCat = SSYMBOL; return COMMA;}
"("           {tokenCat = SSYMBOL; return RIGHT_CIRCLE_BRACKET;}
")"           {tokenCat = SSYMBOL; return LEFT_CIRCLE_BRACKET;}
"["           {tokenCat = SSYMBOL; return RIGHT_SQUARE_BRACKET;}
"]"           {tokenCat = SSYMBOL; return LEFT_SQUARE_BRACKET;}
"{"           {tokenCat = SSYMBOL; return RIGHT_CURLY_BRACKET;}
"}"           {tokenCat = SSYMBOL; return LEFT_CURLY_BRACKET;}
"/*"          {tokenCat = SSYMBOL; return SLASH_STAR;}
"*/"          {tokenCat = SSYMBOL; return STAR_SLASH;}

{id}          {tokenCat = OTOKEN; return ID;}
{num}         {tokenCat = OTOKEN; return NUM;}

{newline}     {lineno++;}
{whitespace}  {/* Skipping White-spaces */}
{comment}     {/* Skipping comments */}
<<EOF>>       {return END;}
.             {tokenCat = ERR; return ERROR;}
{commentError} {tokenCat = CERR; return COMMENT_ERROR;}

%%

int main(int argc, char* argv[])
{
    TokenType currentToken;
    char inputFile[120];

    // Handle arguement reading
    if (argc !=2) {
        fprintf(stderr, "usage: %s <filename>\n", argv[0]);
        exit(1);
    }
    strcpy(inputFile, argv[1]);

    // Handle openning the file
    source = fopen(inputFile, "r");
    if (source== NULL){
        fprintf(stderr, "File %s not found.\n", inputFile);
    }
    yyin = source;

    // Keep asking user for input until they enter "end"
    while ((currentToken = yylex())!= END){
        printToken(yytext);
    }

    // Close the program
    printf("Exiting the scanner.\n");
    fclose(source);
    return 0;
}

void printToken(const char* lexeme){

    switch(tokenCat){
        case RWORD:
            printf("%d: reserved word: %s\n", lineno, lexeme);
            break;
        case SSYMBOL:
            printf("%d: special symbol: %s\n", lineno, lexeme);
            break;
        case OTOKEN:
            printf("%d: ID, name= %s\n", lineno, lexeme);
            break;
        case ERR:
            printf("%d: ERROR: %s\n", lineno, lexeme);
            break;
        case CERR:
            printf("%d: ERROR: EOF in comment\n", lineno);
            break;
        default:
            printf("Unknown category.\n");
            break;
    }
}