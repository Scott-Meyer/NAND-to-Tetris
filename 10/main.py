
import sys
from pathlib import Path
import glob, re, os, itertools

#Given a .jack file, return tokenized.
#First clean the file of blank lines and comments
#NOTE: Will have to remove this part if we want line counts in error messages.
def tokenize(clean_file):
    keywords = {
        'class',
        'constructor',
        'function',
        'method',
        'field',
        'static',
        'var',
        'int',
        'char',
        'boolean',
        'void',
        'true',
        'false',
        'null',
        'this',
        'let',
        'do',
        'if',
        'else',
        'while',
        'return'
    }
    symbols = {'{', '}', '(', ')', '[', ']', '.', ',', ';', '+', '-', '*', '/', '&', '|', '<', '>', '=', '~'}

    def handle_non_symbol(s):

        #keyword
        if s in keywords:
            return {'type':'keyword', 'val':s}
        #stringConstant
        elif s[0] == '"' and s[-1:] == '"':
            return {'type':'stringConstant', 'val':s}
        #integerConstant
        elif re.match('\\d+', s):
            return {'type':'integerConstant', 'val':s}
        #identifier
        elif re.match('[\\w_][a-zA-Z0-9_]*', s):
            return {'type':'identifier', 'val':s}
        #ERROR
        else:
            return {'type':'ERROR', 'val':s}

    items = []
    in_string = False
    tmp = ''
    for i, char in zip(range(len(clean_file)-1), clean_file):
        if in_string:
            tmp += char
            if char == '"':
                in_string = False
        else:
            if char == ' ' or char in symbols:
                if not tmp == '':
                    items.append(handle_non_symbol(tmp))
                    tmp = ''
                if not char == ' ':
                    items.append({'type':'symbol', 'val':char})
            else:
                if char == '"':
                    in_string = True
                tmp += char
    
    return items
    


def clean_file(file):
    '''
    Given a jack file, remove all comments and empty spaces.
    :param str file: location of a file to clean
    :rtype: str
    '''
    de_commented = re.sub('\\/\\/.*|\\/\\*(?s:.)*\\*\\/', '', open(file).read())
    #remove blank lines.
    striped = os.linesep.join([s for s in de_commented.splitlines() if s.strip()])
    return multireplace(striped, {'\r':' ', '\n':' ', '\t': ' '}).strip()

#https://gist.github.com/bgusach/a967e0587d6e01e889fd1d776c5f3729
def multireplace(string, replacements):
    """
    Given a string and a replacement map, it returns the replaced string.
    :param str string: string to execute replacements on
    :param dict replacements: replacement dictionary {value to find: value to replace}
    :rtype: str
    """
    # Place longer ones first to keep shorter substrings from matching where the longer ones should take place
    # For instance given the replacements {'ab': 'AB', 'abc': 'ABC'} against the string 'hey abc', it should produce
    # 'hey ABC' and not 'hey ABc'
    substrs = sorted(replacements, key=len, reverse=True)

    # Create a big OR regex that matches any of the substrings to replace
    regexp = re.compile('|'.join(map(re.escape, substrs)))

    # For each match, look up the new string in the replacements
    return regexp.sub(lambda match: replacements[match.group(0)], string)            

def token_parser(tokens):
    pre = [xml_token(tokens[0]), xml_token(tokens[1])]
    pr, tokens = parse_inner(tokens[2:], prefix=pre)
    r = [
        '<class>',
        pr,
        '</class>'
    ]

    print(r)
    return r

def parse_inner(tokens, prefix=None, end=None):
    '''Parse the inner part of {}
    :rtype: [<> [...] <>], tokens'''
    def token_check(v):
        return tokens[0]['type'] == 'keyword' and tokens[0]['val'] == v

    if end is None:
        end = get_end(tokens[0])

    def is_end(token):
        return token == end

    r = [xml_token(tokens[0])] #Value we are going to return
    tokens = tokens[1:] #slice off the opening, we already added it.

    if prefix is not None:
        r = prefix + r

    #Parse overf all things inside where wheverever we are
    while tokens and not is_end(tokens[0]):
        #classVarDec
        if token_check('static'):
            tl, tokens = parse_var(tokens, 'classVarDec')
            r = r + tl
        #varDec
        elif token_check('var'):
            tl, tokens = parse_var(tokens, 'varDec')
            r = r + tl
        #subroutineDec
        elif token_check('function'):
            rt, tokens = parse_subroutine(tokens)
            r = r + rt
        #letStatement
        elif token_check('let'):
            rt, tokens = parse_let(tokens)
            r = r + rt
        #doStatement
        elif token_check('do'):
            rt, tokens = parse_do(tokens)
            r = r + rt
        #returnStatement
        elif token_check('return'):
            rt, tokens = parse_return(tokens)
            r = r + rt
        #if/else
        elif token_check('if')
            rt, tokens = parse_return(tokens)
            r = r + rt
        else:
            break

    #If we reached the end, add it onto return and return.
    if tokens and is_end(tokens[0]):
        r.append(xml_token(tokens[0]))            
        return r, tokens[1:]
    return r, tokens

def get_end(token):
    ''' Get the ending token to an opening token
    :rtype: token
    '''
    if token == {'type':'symbol', 'val':'{'}:
        return {'type':'symbol', 'val':'}'}
    elif token == {'type':'symbol', 'val':'('}:
        return {'type':'symbol', 'val':')'}
    elif token == {'type':'symbol', 'val':'['}:
        return {'type':'symbol', 'val':']'}
    else:
        print(token)
        sys.exit()

def xml_token(token):
    '''
    Given a token group ['symbol','}'], return a xml string
    :param list token: Token group type ['symbol','}']
    :rtype: str
    '''
    return '<'+token['type']+'> '+token['val']+' </'+token['type']+'>'

def parse_var(tokens, tag):
    '''Parse a var/static
    :ret: [<> [...] <>], tokens'''

    i = 0
    inside_tag = []
    for t in tokens:
        inside_tag.append(xml_token(t))
        i += 1
        if t['val'] == ';':
            break

    rl = [
        '<'+tag+'>',
        inside_tag,
        '</'+tag+'>']
    return rl, tokens[i:]

def parse_subroutine(tokens):
    '''Parse a subroutine decloration
    :rtype: [<> [<><><><><> [...] <><><> [...] <>] <>], tokens'''
    dec = [
        xml_token(tokens[0]), #keyword function
        xml_token(tokens[1]), #keyword type
        xml_token(tokens[2])  #identifier name
    ]
    pl, tokens = param_list(tokens[3:])
    bl, tokens = parse_inner(tokens)
    dec = dec + pl + ['<subroutineBody>', bl, '</subroutineBody>']
    
    r = [
        '<subroutineDec>', dec, '</subroutineDec>',
    ]
    return r, tokens

def param_list(tokens):
    '''Handle the () part of a subroutineDec
    :rtype: [<><> [...] <><>]'''
    r = [xml_token(tokens[0]), '<parameterList>']
    pl = []
    i = 1
    for t in tokens[1:]:
        i += 1
        if t == get_end(tokens[0]):
            if pl:
                r = r + [pl, '</parameterList>', xml_token(t)]
            else: 
                r = r + ['</parameterList>', xml_token(t)]
            break
        else:
            pl.append(xml_token(t))
    return r, tokens[i:]

def parse_let(tokens):
    '''Parse a let statement
    TODO: term
    :rtype:[<>[<><><><>[...]<><>]<>]'''
    r = []
    for i in range(3):
        r.append(xml_token(tokens[i]))
    r.append('<expression>')
    expressions, tokens = expression(tokens[3:], ';')
    r = r + [
        expressions,
        xml_token(tokens[0])
    ]
    return ['<letStatement>']+[r]+['</letStatement>'], tokens[1:]


def expression(tokens, ender):
    i = -1
    expressions = []
    for t in tokens:
        i += 1
        if not t['val'] == ender:
            expressions.append(xml_token(t))
        else:
            break
    return ['<expression>']+[expressions]+['</expression>'], tokens[i:]

def parse_do(tokens):
    '''
    '''
    r = [xml_token(tokens[0])] #Get that "do" in there
    i = 0
    for t in tokens[1:]:
        i += 1
        if not t['val'] == '(':
            r.append(xml_token(t))
        else:
            pl, tokens = param_list(tokens[i:])
            r = r + pl + [xml_token(tokens[0])]
            break

    return ['<doStatement']+[r]+['</doStatement>'], tokens[1:]

def parse_return(tokens):
    '''
    '''
    r = []
    if tokens[1]['val'] == ';': #Then its 'return;' so...
        r = [xml_token(tokens[0]), xml_token(tokens[1])]
        tokens = tokens[2:]
    return ['<returnStatement>']+[r]+['</returnStatement>'], tokens

def parse_if(tokens):
    '''
    '''
    r = []


    return ['<ifStatement>'] + [r] + ['</ifStatement>'], tokens

#Saved a file and tokenized as a XML.
def save_xml(file, xml):
    pxml = "" #This will be proper XML

    def r_xml(xs, i):
        r = ""
        if not xs:
            return r
        else:
            indent = ''.join(['  ' for n in range(i)])
            for x in xs:
                if isinstance(x, str):
                    r = r + indent + x + '\n'
                else:
                    r = r + r_xml(x, i+1)
            return r

    print(r_xml(xml, 0))
    print('stuff')

#Given paths, get all .jack files.
def get_all_files(paths):
    files = []
    for arg in paths:
        path = Path(arg)
        #If the path exists, we need to add jack files to the files list, otherwise skip it.
        if path.exists():
            #If its a jack file, add to files.
            if arg.endswith('.jack'):
                files.append(arg)
            #If its a directory, add all .jack files in the directory
            elif path.is_dir():
                if not arg.endswith('/'):
                    arg = arg + '/'
                    files = files + glob.glob(arg + '*.jack')
            #If its none of the above skip it.
            else:
                print("Not folder or .jack file skipping: " + arg)
        else:
            print("Not Found: " + arg)
    return files

if __name__ == '__main__':
    print("Now running NAND Project 10.")
    
    #Get all files from the arguments. (If folder get .jack in that folder)
    args = sys.argv[1:]
    files = get_all_files(args)

    #Tokenize every file
    #tokenized_files = map(tokenize, files)
    cleaned_files = map(clean_file, files)
    tokenized_files = map(tokenize, cleaned_files)
    xml_ready = map(token_parser, tokenized_files)
    #for item in list(tokenized_files)[0]:
    #    print(item)
    save_xml('', list(xml_ready)[0])
    #Save every tokenized file as a xml
    #for file, tokenized in zip(files, tokenized_files):
    #    save_xml(file, tokenized)

    print("Done tokenizing all these files: ")
    print(files)