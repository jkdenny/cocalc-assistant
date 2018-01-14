#!/usr/bin/env coffee
# read the .js files
# for now, we only do this for the physical constants

fs = require('fs')

define = (x) -> x

header = ->
    '''
    # CoCalc Examples Documentation File
    # Copyright: CoCalc Authors, 2018
    # This is derived content from the BSD licensed https://github.com/moble/jupyter_boilerplate/

    # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # THIS FILE IS AUTOGENERATED -- DO NOT EDIT BY HAND #
    # # # # # # # # # # # # # # # # # # # # # # # # # # #

    ---
    language: python
    ''' + '\n'

read_submenu = (entry, cat0, name_prefix, cat_prefix, entry_extra, cat_process) ->
    entry_extra ?= ->
    cat_process ?= (x) -> x
    if name_prefix?
        prefix = "#{name_prefix} / "
    else
        prefix = ''
    submenu  = entry['sub-menu']
    cat1     = cat_process(entry['name'])
    output   = []

    if cat1 == 'Example'
        return output

    output.push('---')
    output.push("category: ['#{cat0}', '#{prefix}#{cat1}']")
    if cat_prefix?
        output.push("prefixes: #{JSON.stringify(cat_prefix)}")

    for entry in entry['sub-menu']
        # there are weird "---"
        if typeof entry == 'string'
            continue
        # oh yes, sub entries can have subentries ... just skipping them via recursion.
        if entry['sub-menu']?
            output = output.concat(read_submenu(entry, cat0, cat1, cat_prefix, entry_extra, cat_process))
        else
            output.push('---')
            extra = entry_extra(entry)
            output.push(extra) if extra?
            output.push("title: |\n  #{entry.name}")
            #console.log(JSON.stringify(entry))
            code = ("  #{x}" for x in entry.snippet).join('\n')
            output.push("code: |\n#{code}")
    return output

# This is specific to scipy special functions file
read_scipy_special = ->
    special_js   = fs.readFileSync('tmp/jupyter_boilerplate/snippets_submenus_python/scipy_special.js', 'utf8')
    constants    = eval(special_js)
    output       = []
    cat_prefix   = {'special': 'from scipy import special'}

    entry_extra = (entry) ->
        if entry.snippet.join('\n').indexOf('special') != -1
            return 'prefix: "special"'

    for entry in constants['sub-menu']
        if entry['sub-menu']?
            output = output.concat(read_submenu(entry, 'Scipy', 'Special', cat_prefix, entry_extra, null))

    content = header()
    content += output.join('\n')

    fs.writeFileSync('src/python/scipy_special.yaml', content, 'utf8')

# This is specific to matplotlib file
read_matplotlib = ->
    matplotlib_js  = fs.readFileSync('tmp/jupyter_boilerplate/snippets_submenus_python/matplotlib.js', 'utf8')
    constants      = eval(matplotlib_js)
    output         = []
    cat_prefix     = {'matplotlib': '''
                                    import numpy as np
                                    import matplotlib as mpl
                                    import matplotlib.pyplot as plt
                                    '''
    }

    entry_extra = (entry) ->
        s = entry.snippet.join('\n')
        if s.indexOf('mpl.') != -1 or s.indexOf('plt.') != -1
            return 'prefix: "matplotlib"'

    for entry in constants['sub-menu']
        if entry['sub-menu']?
            output = output.concat(read_submenu(entry, 'Visualization', null, cat_prefix, entry_extra, null))

    content = header()
    content += output.join('\n')

    fs.writeFileSync('src/python/boilerplate_matplotlib.yaml', content, 'utf8')



# This is specific to the constants file, prints out yaml to stdout
read_constants = ->
    constants_js = fs.readFileSync('tmp/jupyter_boilerplate/snippets_submenus_python/scipy_constants.js', 'utf8')
    constants    = eval(constants_js)
    output       = []
    cat_prefix   = {'constants': 'from scipy import constants'}

    entry_extra = (entry) ->
        if entry.snippet.join('\n').indexOf('constants') != -1
            return 'prefix: "constants"'

    cat_process = (cat) ->
        return cat.replace('physical constants', '').trim()

    for entry in constants['sub-menu']
        if entry['sub-menu']?
            output = output.concat(read_submenu(entry, 'Constants', null, cat_prefix, entry_extra, cat_process))

    content = header()
    content += output.join('\n')

    fs.writeFileSync('src/python/constants.yaml', content, 'utf8')

main = ->
    read_constants()
    read_scipy_special()
    read_matplotlib()

main()