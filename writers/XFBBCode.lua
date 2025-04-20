Writer = pandoc.scaffolding.Writer

function bb_enclose(tag, content, argument)
    pre = pandoc.layout.brackets(argument and string.format('%s=%s', tag, argument) or tag)
    render = pandoc.utils.type(content) == "Inlines" and Writer.Inlines or Writer.Blocks
    post = pandoc.layout.brackets('/' .. tag)
    return pandoc.layout.inside(render(content), pre, post)
end

function container(container, group, render)
    _, vsmall = container.classes:find('vsmall')
    _, small = container.classes:find('small')
    _, large = container.classes:find('large')
    _, vlarge = container.classes:find('vlarge')
    _, book = container.classes:find('book')
    _, verdana = container.classes:find('verdana')
    _, tt = container.classes:find('tt')
    _, indent = container.classes:find('indent')

    if vsmall then
        container.classes:remove(vsmall)
        return bb_enclose('SIZE', group(container), '1')
    elseif small then
        container.classes:remove(small)
        return bb_enclose('SIZE', group(container), '2')
    elseif large then
        container.classes:remove(large)
        return bb_enclose('SIZE', group(container), '4')
    elseif vlarge then
        container.classes:remove(vlarge)
        return bb_enclose('SIZE', group(container), '5')
    elseif book then
        container.classes:remove(book)
        return bb_enclose('FONT', group(container), 'book antiquia')
    elseif verdana then
        container.classes:remove(verdana)
        return bb_enclose('FONT', group(container), 'verdana')
    elseif tt then
        container.classes:remove(tt)
        return bb_enclose('FONT', group(container), 'courier new')
    elseif indent then
        container.classes:remove(indent)
        return bb_enclose('INDENT', group(container))
    else
        return render(container.content)
    end
end

function Writer.Block.BlockQuote(blockquote)
    return bb_enclose('INDENT', blockquote.content)
end

function Writer.Block.BulletList(header)
    return nil
end

function Writer.Block.CodeBlock(header)
    return nil
end

function Writer.Block.DefinitionList(header)
    return nil
end

function Writer.Block.Div(div)
    return container(div, pandoc.Blocks, Writer.Blocks)
end

function Writer.Block.Figure(header)
    return nil
end

function Writer.Block.Header(header)
    tag = string.format('H%d', header.level)
    return bb_enclose(tag, header.content)
end

function Writer.Block.HorizontalRule(header)
    return '[HR]'
end

function Writer.Block.Para(para)
    return pandoc.layout.nowrap(Writer.Inlines(para.content)) ..
        pandoc.layout.before_non_blank(pandoc.layout.blankline)
end

function Writer.Inline.Emph(emph)
    return bb_enclose('I', emph.content)
end

Writer.Inline.LineBreak = pandoc.layout.cr

function Writer.Inline.Link(link)
    return container(link, pandoc.Inlines, function (content)
        return bb_enclose('URL', content, link.target)
    end)
end

function Writer.Inline.Quoted(quoted)
    quote = quoted.quotetype == "DoubleQuote"
        and pandoc.layout.double_quotes
        or pandoc.layout.quotes
    return quote(Writer.Inlines(quoted.content))
end

function Writer.Inline.RawInline(rawinline)
    return rawinline.text
end

Writer.Inline.SoftBreak = pandoc.layout.space
Writer.Inline.Space = pandoc.layout.space

function Writer.Inline.Span(span)
    return container(span, pandoc.Inlines, Writer.Inlines)
end

function Writer.Inline.Str(str)
    return str.text
end

function Writer.Inline.Strikeout(strikeout)
    return bb_enclose('S', strikeout.content)
end

function Writer.Inline.Strong(strong)
    return bb_enclose('B', strong.content)
end
