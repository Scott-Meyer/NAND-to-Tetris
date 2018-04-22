
import sys
from pathlib import Path
import glob, re, os, itertools, copy

'''
    Whether the identifier is presently being defined (e.g. the identifier stands for a variable declared in a "var" statement) or used.
'''

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
    stage1 = {'var', 'static', 'field',  'class', 'constructor', 'function', 'method', 'argument'}
    stage1_indexed = {'var', 'static', 'field', 'argument'}
    symbols = {'{', '}', '(', ')', '[', ']', '.', ',', ';', '+', '-', '*', '/', '&', '|', '<', '>', '=', '~'}

    def handle_non_symbol(s):
        #keyword
        if s in keywords:
            #Going to enter specific added info for some types
            #vrs
            return {'type':'keyword', 'val':s}
        #stringConstant
        elif s[0] == '"' and s[-1:] == '"':
            return {'type':'stringConstant', 'val':s[1:-1]}
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
    defined  = set()
    in_string = False
    instage = None
    index = 0
    tmp = ''
    for i, char in zip(range(len(clean_file)), clean_file):
        if in_string:
            tmp += char
            if char == '"':
                in_string = False
        else:
            if char == ' ' or char in symbols:
                if not tmp == '':
                    # Upgrading this for stage one of project 11
                    handled_non = handle_non_symbol(tmp)
                    #If we are in a stage1 (var/class) then this needs item needs to have extra info put on it.
                    if instage is not None:
                        if instage['category'] in stage1_indexed: #Something also require an index
                            #Every var needs a type:
                            if instage['category'] in {'var', 'static', 'field'}:
                                if 'var_type' in instage:
                                    instage['index'] = index
                                    index += 1
                                    handled_non.update(instage)
                                else:
                                    instage['var_type'] = tmp
                            else: # THIS IS WHERE ARGUMENTS ARE HANDLED
                                #Arguments are 'type thing' and types are keywords
                                if handled_non['type'] == 'keyword':
                                    instage['var_type'] = handled_non['val']
                                    handled_non.update({'arg_type':True})
                                else:
                                    instage['index'] = index
                                    index += 1
                                    handled_non.update(instage)
                                    instage.pop('var_type', None)
                        # Every function/subroutine needs a type keyword.
                        elif instage['category'] in {'constructor', 'function', 'method'}:
                            if 'sub_type' in instage:
                                del instage['sub_type']
                                handled_non.update(instage)
                            else:
                                instage['sub_type'] = True
                        else:
                            handled_non.update(instage)
                    elif handled_non['val'] in stage1:
                        if instage is not None: sys.exit()
                        instage = {'category':handled_non['val']}

                    #Stage_1, last part. If we added a category, we know the item is being defined.
                    #    So we are going to add it to defined, so if it is used later, we know its not being defined
                    if 'category' in handled_non:
                        handled_non['defined'] = True
                        defined.add(tmp)
                    #now we have to add ['defined'] = false, if the item is not being defined, and has been defined.
                    elif tmp in defined:
                        handled_non['defined'] = False

                    #Still append handle_non_symbol, but possibly with extra info added.
                    items.append(handled_non)
                    tmp = ''
                if not char == ' ':
                    ''' not doing XML anymore
                    if char == '<':
                        char = '&lt;'
                    if char == '>':
                        char = '&gt;'
                    if char == '&':
                        char = '&amp;'
                    '''
                    # We have to handle ending of instage. (like vars end on ; if in sub we gota look out for () and arguments.
                    if instage is not None:
                        #this is variable types. They end in ;
                        if instage['category'] in {'var', 'static', 'field'} and char == ';':
                            instage = None
                        #This is for subroutines. They end in ( because now its possibly argument time
                        elif instage['category'] in {'constructor', 'function', 'method'} and char == '(':
                            instage = {'category':'argument'}
                        elif instage['category'] == 'argument' and char == ')':
                            instage = None
                        #end class on {
                        elif instage['category'] == 'class' and char == '{':
                            instage = None

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
    #de_commented = re.sub('\\/\\/.*|\\/\\*(?s:.)*\\*\\/', '', open(file).read())
    de_commented = re.sub('\/\/.*|\/\*[^*]*\*+(?:[^\/*][^*]*\*+)*\/', '', open(file).read())
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

def vm_files(files):
    r = []
    for file in files:
        r.append(file[:-5] + '.vm')
    return r


#New saver, no need for the old fun recursion for tabs
def save_vm_file(file, vm):
    with open(file, 'w') as text_file:
        text_file.write('\n'.join(vm))


#############-----------BEING PROJECT 11-----------#############
#yes I know parser should be in project 10, but I fail =/
#########--------- BEGIN PARSER ---------#########
def parse(tokens):
    #First thing is a class which ends with a }
    #new_thing(tokens, 0, '}')
    print('thing')

#########---------Class for easy adding of lines to print ---------#########
class line_writer:
    lines = []

    def __init__(self):
        self.lines = []

    def Push(self, segment, index):
        self.lines.append("push {0} {1}".format(segment, index))

    def Pop(self, segment, index):
        self.lines.append("pop {0} {1}".format(segment, index))

    def Arithmatic(self, command):
        self.lines.append(command)

    def Label(self, label, counter):
        self.lines.append("label {0}".format(label + str(counter)))

    def Goto(self, label, counter):
        self.lines.append("goto {0}".format(label + str(counter)))

    def If(self, label, counter):
        self.lines.append("if-goto {0}".format(label + str(counter)))

    def Call(self, name, nArgs):
        self.lines.append("call {0} {1}".format(name, nArgs))

    def Function(self, name, nLocals):
        self.lines.append("function {0} {1}".format(name, nLocals))

    def append(self, s):
        self.lines.append(s)

    def Return(self):
        self.lines.append("return")

#########--------- SYMBOL TABLE OBJECT ---------######### 

#########--------- CODE GENERATION ---------#########
class code_generator:
    ''' I Created this as a class because I thought I would need some globals that would
    be easy to reset (IE new class for new file).

    I actually didn't really need it. I could have use Dics and had a new file function that
    re-initialized the dics. Infact some of the things I really thought I needed it for
    like 'symbol_table' I ended up not using at all, I did a  immuntable style because
    it made undoing recurcs down easier... The whole reason I made a class was so I could make it
    static and keep things over into other files... which I ended up not needing.

    In the end this class really messed with the 'prettyness' of my code.
        without benefit.

    I ended up making some random 'global' class variables just to feel better about myself :'(
    '''
    classVar = {'field', 'static'}
    subDec = {'constructor','function','method'}
    validSegNames = {'static','argument','local','this','that','constant','pointer','temp'}
    whiles = 0
    ifs = 0
    lines = 0
    file = []
    i = 0
    where = []

    #SYMBOL TABLE
    '''
    table[token['val']] = {
        'type': token['var_type'],
        'category': token['category'],
        'index':index
    }
    '''
    symbol_table = {
        '-+indices':{
            'static':0,
            'field':0,
            'argument':0,
            'var':0
        }
    }


    def __init__(self, file):
        self.whiles = 0
        self.ifs = 0
        self.lines = line_writer()
        self.file = []
        self.i = 0
        self.where = []
        self.file = file
        assert(file[0]['val'] == 'class')
        self.i = 0
        self.open(self.symbol_table)
        #return self.lines.lines

    #process opening a new thing that has a body
    def open(self, symbol_table):
        #Scope. As we go deeper we gain things, but when we go back up we want to loose them.
        symbol_table = copy.deepcopy(symbol_table)

        #open_class
        if file[self.i]['val'] == 'class':
            ## Get the class all setup (some asserts to check tokens are right class, name, {)
            assert(file[self.i+1]['type'] == 'identifier')
            self.class_name = file[self.i+1]['val']
            assert(file[self.i+2]['val'] == '{')

            #Class should open with static/field
            #Move iteration count paste opening brace
            self.i += 3
            self.class_body('}', symbol_table)
        #open_function
        elif file[self.i]['val'] == 'function':
            self.i += 2
            line = file[self.i]['category']
            line = line + " " + self.class_name
            line = line + '.' + file[self.i]['val']
            line = line + ' ' + '0'
            self.lines.append(line)
            
            #Pass over arguments, do later
            self.i += 3
            self.class_body('}', symbol_table)
        #open something else
        elif file[self.i]['val'] == 'var':
            print('var')
        #Should only be called with an open
        else:
            raise ValueError("Open called with wrong thing {0}".format(file[self.i]))

    #process the body of something, ends with a } or a ;
    def class_body(self, end, symbol_table):
        #Scope. As we go deeper we gain things, but when we go back up we want to loose them.
        symbol_table = copy.deepcopy(symbol_table)
        #These are the functions used when different token values are found.
        how_to_handle = {
            'field':self.handle_class_var_dec, #Done
            'static':self.handle_class_var_dec,
            'constructor':self.handle_subroutine, #Done
            'function':self.handle_subroutine,
            'method':self.handle_subroutine
        }
        #Go until end or EOF
        while file[self.i]['val'] != end and self.i < len(file):
            how_to_handle[file[self.i]['val']](symbol_table)

    def subroutine_body(self, token, table):
        assert(file[self.i]['val'] == '{')
        self.i += 1

        #these are functions used when different token values are found.
        how_to_handle = {
            'var':self.handle_class_var_dec, #modify class var to allow non-class var
            'let':self.handle_let,          #Second, (ConvertToBin)
            'if':self.handle_if,            #Second, (ConvertToBin)
            'while':self.handle_while,      #Second, (ConvertToBin)
            'do':self.handle_do,            #First, (Seven)
            'return':self.handle_return     #First, (Seven)
        }

        while file[self.i]['val'] != '}' and file[self.i]['val'] == 'var':
            how_to_handle[file[self.i]['val']](table)

        #Gota print the function now.
        self.lines.Function(self.class_name+'.'+token['val'], table['-+indices']['var'])

        if token['category'] == 'constructor':
            if table['-+indices']['field'] > 0:
                self.lines.Push('constant', table['-+indices']['field'])
            self.lines.Call('Memory.alloc', 1)
            self.lines.Pop('pointer', 0)
        elif token['category'] == 'method':
            self.lines.Push('argument', 0)
            self.lines.Pop('pointer', 0)

        while file[self.i]['val'] != '}':
            if file[self.i]['val'] == 'var':
                raise ValueError("VAR decloration after other thin in " + token['val'])
            how_to_handle[file[self.i]['val']](table)

    def body(self, table):
        '''
        This is specifically bodies that arn't class/func IE random {} statements
        '''
        #THIS USED TO BE an assert, but I call it sometimes moving over sometimes not.
        #Now this is a hack fix
        assert(file[self.i]['val'] == '{')
        self.i += 1

        #these are functions used when different token values are found.
        how_to_handle = {
            'var':self.handle_class_var_dec, #modify class var to allow non-class var
            'let':self.handle_let,          #Second, (ConvertToBin)
            'if':self.handle_if,            #Second, (ConvertToBin)
            'while':self.handle_while,      #Second, (ConvertToBin)
            'do':self.handle_do,            #First, (Seven)
            'return':self.handle_return     #First, (Seven)
        }

        while file[self.i]['val'] != '}':
            how_to_handle[file[self.i]['val']](table)

    ####--- all of the random handles (DO/while/if/etc..) ---####
    def handle_do(self, table):
        ''' handles a do statement, from bodies, takes a table it can mutate'''
        assert(file[self.i]['val'] == 'do')
        self.i += 1
        self.handle_sub_call(table)
        #pop off the return from the do
        self.lines.Pop('temp', 0)

    def handle_let(self, table):
        ''' handles a let statement, from bodies, takes a table it can mutate'''
        if file[self.i]['val'] != 'let':
            raise ValueError('Called handle Let when not let {0}'.format(file[self.i]))
        self.i += 1 #skip over the let word
        array = False

        #TODO: Add check that this var has been defined
        var = file[self.i]
        sym = table[var['val']]
        self.i += 1

        if file[self.i]['val'] == '[': #Array
            self.handle_array(table) #GOT EEET
            array = True

            self.lines.Push(sym['category'], sym['index'])
            self.lines.Arithmatic('add')
            self.lines.Pop('temp', 2)
        
        if file[self.i]['val'] != '=':
            raise ValueError("Not = on handle let instead {0}".format(file[self.i]))
        self.i += 1

        self.handle_expression(table) #expression after =

        if array:
            self.lines.Push('temp', 2)
            self.lines.Pop('pointer', 1)
            self.lines.Pop('that', 0)
        else:
            self.lines.Pop(sym['category'], sym['index'])
        #some problems with expression ending at weird places... Id on't feel like fixing.
        #TODO: Fix needing this hack
        if file[self.i]['val'] == ';':
            self.i += 1



    def handle_if(self, table):
        '''
        Very commented and asserted version (kinda similar to while)
        for testing and understanding.
        '''
        #Number of ifs (before/after stuffs) YAY use class (=( )
        assert(file[self.i]['val'] == 'if')
        i = self.ifs
        self.ifs += 1
        self.i += 1

        assert(file[self.i]['val'] == '(') #then pass it over
        self.i += 1

        self.handle_expression(table) #because now we need the if expression (table mutates)
        assert(file[self.i]['val'] == ')') #see handled correctly, then pass it over
        self.i += 1

        self.lines.Arithmatic('not')
        assert(file[self.i]['val'] == '{') #then pass it over

        self.lines.If('IF_FALSE', i)
        self.body(table) #body of if
        self.lines.Goto('IF_TRUE', i)
        assert(file[self.i]['val'] == '}')
        self.i += 1

        self.lines.Label('IF_FALSE', i)

        if file[self.i]['val'] == 'else':
            self.i += 1 #skip over the else, we know its there
            assert(file[self.i]['val'] == '{')

            self.body(table) #else {} body
            assert(file[self.i]['val'] == '}')
            self.i += 1
        self.lines.Label('IF_TRUE', i)

    def handle_while(self, table):
        '''handle a while statement (from bodies) takes a table it will mutate'''
        #Number of whiles (before/after stuffs) YAY use class (=( )
        i = self.whiles
        self.whiles += 1

        self.lines.Label('WHILES_CONDITION', i)

        self.i += 1
        assert(file[self.i]['val'] == '(')
        self.i += 1
        self.handle_expression(table)
        assert(file[self.i]['val'] == ')')

        self.lines.Arithmatic('not')
        self.i += 1
        assert(file[self.i]['val'] == '{')
        self.lines.If('WHILES_END', i)

        self.body(table)
        self.lines.Goto('WHILES_CONDITION', i)
        assert(file[self.i]['val'] == '}')
        self.i += 1

        self.lines.Label('WHILES_END', i)
    
    
    def handle_return(self, table):
        '''handle a return statement (found in sub_body) takes a table it will mutate'''
        #pass the return keyword:
        self.i += 1

        #see if empty return
        if file[self.i]['val'] == ';':
            self.lines.Push('constant', 0)
        else:
            self.handle_expression(table)
            if file[self.i]['val'] != ';':
                raise ValueError('not ; after handle return exp {0}'.format(file[self.i]))
        self.i += 1
        self.lines.Return()


    def handle_sub_call(self, table):
        '''Handle calling of a subroutine, takes a symbol table that it will edit'''
        ati = file[self.i]['val']
        args = 0
        def do_args(args):
            assert(file[self.i]['val'] == '(')
            self.i += 1

            while file[self.i]['val'] != ')':
                fi = file[self.i]
                #if , just skip it and re-loop
                if fi['val'] == ',':
                    self.i += 1
                else:
                    self.handle_expression(table)
                    args += 1
            self.i += 1 #MOVE past )
            return args

        #WATCH THESE self.i += n... I did some of them wrong, just changed one to 3
        #non-self
        if file[self.i+1]['val'] == '.': #Then it is a class
            if ati[0].isupper():
                name = ati + '.' + file[self.i+2]['val']
            else:
                name = table[ati]['type'] + '.' + file[self.i+2]['val']
                self.lines.Push(table[ati]['category'], table[ati]['index'])
                args = 1
            self.i += 3
        #self
        else: #Then its a local function
            name = self.class_name + '.' + ati
            self.lines.Push('pointer', 0)
            self.i += 1
            args = 1

        args = do_args(args)
        
        if file[self.i]['val'] == ';':
            self.lines.Call(name, args)
            self.i += 1 #Move past ;
        else:
            return
            #raise ValueError("missing ; or something {0}".format(file[self.i]))


    def handle_expression(self, table):
        '''
        Handle expressions (THIS IS REALLY IMPORTANT)
        called for things inside the () on ifs/whiles, also after = on lets. and more.
        '''
        self.handle_term(table)
        def while_pass(d):
            v = d['val']
            return (
                v == '+' or v == '=' or v == '<' or v == '>' or v == '|' or
                v == '&' or v == '*' or v == '/' or v == '-'
            )

        while while_pass(file[self.i]):
            fi = file[self.i]
            v = fi['val']
            self.i += 1
            self.handle_term(table)

            if fi['val'] == '+':
                self.lines.Arithmatic('add')
            elif v == '-':
                self.lines.Arithmatic('sub')
            elif v == '/':
                self.lines.Arithmatic('call Math.divide 2')
            elif v == '*':
                self.lines.Arithmatic('call Math.multiply 2')
            elif v == '=':
                self.lines.Arithmatic('eq')
            elif v == '<':
                self.lines.Arithmatic('lt')
            elif v == '>':
                self.lines.Arithmatic('gt')
            elif v == '&':
                self.lines.Arithmatic('and')
            elif v == '|':
                self.lines.Arithmatic('or')
            else:
                raise ValueError('no thing in if/fall handle exp {0}'.format(fi))

    #handle random terms
    def handle_term(self, table):
        '''
        Handle singular terms within expressions, takes a table it will mutate
        Warning, can re-call handle_expression because of ()
        '''
        #Because I use it a lot later
        def is_keyw(ln):
            return ln['type'] == 'keyword'
        
        fi = file[self.i] #file at i
    

        if fi['type'] == 'integerConstant':
            self.lines.Push("constant", file[self.i]['val'])
            self.i += 1
        elif fi['type'] == 'stringConstant':
            #Get the string
            st = fi['val']
            self.lines.Push('constant', len(st))
            self.lines.Call('String.new', 1)
            for i in range(len(st)):
                self.lines.Push('constant', ord(st[i]))
                self.lines.Call('String.appendChar', 2)
            self.i += 1
        elif (is_keyw(fi) and fi['val'] == 'true'):
            self.lines.Push('constant', 1)   #TODO: Sometimes this is wrong, should be 0, not... working on it.
            self.lines.Arithmatic('neg')
            self.i += 1
        elif (is_keyw(fi) and fi['val'] == 'null') or (is_keyw(fi) and fi['val'] == 'false'):
            self.lines.Push('constant', 0)
            self.i += 1
        elif is_keyw(fi) and fi['val'] == 'this':
            self.lines.Push('pointer', 0)
            self.i += 1
        elif fi['val'] == '~' or fi['val'] == '-':
            self.i += 1
            st = fi['val']
            self.handle_term(table)

            if st == '~':
                self.lines.Arithmatic('not')
            else:
                self.lines.Arithmatic('neg')
        elif fi['type'] == 'identifier':
            self.i += 1
            if file[self.i]['val'] == '[':
                self.lines.Push(table[fi['val']]['category'], table[fi['val']]['index'])
                self.handle_array(table) #woo so close
                self.lines.Arithmatic('add')
                self.lines.Pop('pointer', 1)
                self.lines.Push('that', 0)
                #self.i += 1
            elif (file[self.i]['val'] == '(') or (file[self.i]['val'] == '.'):
                self.i -= 1
                self.handle_sub_call(table)
            else:
                self.lines.Push(table[fi['val']]['category'], table[fi['val']]['index'])
        elif fi['type'] == 'symbol':
            #Worth knowing. This is about to recur down with calling handle_expression which called this function. Stupid ()
            if fi['val'] == '(':
                self.i += 1
                self.handle_expression(table)
                if file[self.i]['val'] == ')':
                    self.i += 1
                else:
                    raise ValueError('No closing ) inside handle term')
        else:
            raise ValueError('No thing in handle term if/fall {0}'.format(fi))

    def handle_array(self, table):
        def leadingup():
            t = ""
            for i in range(5):
                t = t + (file[self.i - 4 + i]['val'])
            return t
        #print("RIGHT IN ARRAY LAND WITH {0}".format(leadingup()))
        self.i += 1 #skip over [
        self.handle_expression(table)
        #print("RIGHT OUT OF ARRAY HANDLE_EXP WITH {0}".format(leadingup()))
        if file[self.i]['val'] != ']':
            print(file[self.i-5])
            print(file[self.i-4])
            print(file[self.i-3])
            print(file[self.i-2])
            print(file[self.i-1])
            print(file[self.i])
            raise ValueError('No close ] inside handle array {0}'.format(file[self.i]))
        self.i += 1 #skip over ]

    def handle_arguments(self, table):
        '''handle the () part of funcs and such.'''
        while file[self.i]['val'] != ')':
            #skip over ,s
            if file[self.i]['val'] == ',':
                self.i += 1
            #----going to have to do some messy manual handling of types in arguments.
            elif 'arg_type' in file[self.i]:
                #is the type of an argument
                self.i += 1
            #We did some dirty handling of normal types in the tokenizer, but I didn't bother to handle strange types, like classes and such. So if two things back to back are arguments, thats whats happening. We can fix it here
            elif 'category' in file[self.i] and 'category' in file[self.i+1] and file[self.i]['category'] == 'argument' and file[self.i]['category'] == 'argument':
                file[self.i+1]['var_type'] = file[self.i]['val']
                self.i += 1
            #---done with messy fix
            elif 'category' in file[self.i] and file[self.i]['category'] != 'argument':
                raise ValueError("Found non-argument while doing argument loop, missing ')'?")
            else: #Here is where the argument lives
                self.add_symbol(file[self.i], table)
                self.i += 1
        #now skip over the close )
        #self.i += 1

    def handle_class_var_dec(self, table):
        #advance paste 'field array' because we store that info in each named thing.
        self.i += 2

        #handle all of the symbols until ; (mainly just skip over , and call add_symbol)
        while(file[self.i]['val'] != ';'):
            #If its a comma, move on to the next value.
            if file[self.i]['val'] == ',':
                self.i += 1
            else: #not a comma, so it should be a value
                if not 'var_type' in file[self.i]:
                    raise ValueError("class var dec found non-typed token before finding a ';', are you missing a ;? or do you have a tailing ,?")
                #Handle a value
                self.add_symbol(file[self.i], table)
                self.i += 1
        #lastly, skip over the ; before we go back to wherever we where.
        self.i += 1
    def handle_subroutine(self, table):
        #We don't want to edit the symbol table, because when the subroutine ends we want to go back to the last state
        symbol_table = copy.deepcopy(table)

        #we store the category (function/method) in the token so pass
        self.i +=1
        #we forgot to store type, so add it
        file[self.i+1]['var_type'] = file[self.i]['val']
        self.i +=1

        dec_token = file[self.i]
        #if its a method, add this to arguments (like self in python WOO)
        if file[self.i]['category'] == 'method':
            this = {'val':'this', 'var_type':self.class_name, 'category':'argument'}
            self.add_symbol(this, symbol_table)

        #If there are no arguments.
        if file[self.i+2]['val'] == ')':
            self.i += 2
        #There are arguments
        elif file[self.i+1]['val'] == '(': 
            self.i += 2 #skip the (
            self.handle_arguments(symbol_table)
        else:
            raise ValueError("No ( after function name")
        
        ##ADDING THIS TO FIX AN ERROR, but I feel like it should have been done elsewhere.... may need to come back
        if file[self.i]['val'] == ')':
            self.i += 1
        else:
            raise ValueError('no ) after arguments {0}'.format(file[self.i]))
        #AHH bug fixing days later lol

        if file[self.i]['val'] == '{':
            self.subroutine_body(dec_token, symbol_table)
        else:
            raise ValueError( 'No opening brace after function instead {0}'.format(file[self.i]) )

        if file[self.i]['val'] != '}':
            raise ValueError('no } but out of handle subroutine body')
        else:
            #go past the } and we will return out.
            self.i += 1
        return
    ####--- END random handles ---####

    def add_symbol(self, token, table):
        '''Work on symbol table modification. Takes a token file[i] and mutable table'''
        def add_token(index, cat):
            if 'var_type' not in token:
                raise ValueError('var_type not in add_symbol {0}'.format(token))
            table[token['val']] = {
                'type': token['var_type'],
                'category': cat,
                'index':index
            }
        token_cat = token['category']

        #Problems with field/var not being what is in the .vm files normally
        cat = token_cat
        if token_cat == 'field':
            cat = 'this'
        elif token_cat == 'var':
            cat = 'local'
        
        add_token(table['-+indices'][token_cat], cat)
        table['-+indices'][token_cat] += 1

    def compile_expression(self, expNextChar):
        print('stuff')

    def compile_file(self, ender):
        print(self.file)

    def has_type(self, i):
        if 'type' in file[i]:
            return True
        else:
            raise ValueError("Given " + i + "index which is " + file[i] + " and doesn't have a type")
##########--------END PROJECT 11 COMPILE FILE --------##########

if __name__ == '__main__':
    print("Now running NAND Project 10.")
    
    #Get all files from the arguments. (If folder get .jack in that folder)
    while True:
        var = str(input("Want to do another folder/file? (type 'exit' to quit) "))
        if var == 'exit':
            sys.exit()

        files = get_all_files([var])
        vmfiles = vm_files(files)
        #Tokenize every file
        #tokenized_files = map(tokenize, files)
        cleaned_files = map(clean_file, files)
        tokenized_files = map(tokenize, cleaned_files)
        compiled_files = []
        for file in tokenized_files:
            #print(file)
            generated_code = code_generator(file)
            compiled_files.append(generated_code.lines.lines)
            #print(code_generator(file).lines.lines)

        #Save every tokenized file as a xml
        for file, compiled in zip(vmfiles, compiled_files):
            save_vm_file(file, compiled)

        print("Done tokenizing all these files: ")
        for file, nfile in zip(files, vm_files(files)):
            print('[' + file + ' --> ' + nfile + ']')