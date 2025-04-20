if not FORMAT:match('html') and not FORMAT:match('epub') then
    function Div(elem)
        function Para(elem)
            isUsername = function (elem)
                if elem.classes ~= nil then
                    return elem.classes:includes('username')
                end
            end

            _, index = elem.content:find_if(isUsername, 1)
            if index ~= nil then
                elem.content[index + 1] = pandoc.LineBreak()
            end
            return elem
        end

        if elem.classes:includes('chat') then
            elem.content = elem.content:walk({ Para = Para })
            return elem
        end
    end

    function Span(elem)
        if elem.classes:includes('username') then
            elem.content:insert(1, pandoc.Str("<"))
            elem.content:insert(pandoc.Str(">"))
            return elem
        end
    end
end
