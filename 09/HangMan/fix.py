
file = open('words.txt')

good_words = []
for word in file:
    if len(word) > 8:
        if ' ' not in word:
            if '-' not in word:
                if '_' not in word:
                    good_words.append(word)

outfile = open('fixed_words.txt', 'w')
for word in good_words:
    outfile.write('"' + word[:-1] + '",')