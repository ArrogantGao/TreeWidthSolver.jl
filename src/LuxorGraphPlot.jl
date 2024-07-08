using LuxorGraphPlot

function LuxorGraphPlot.GraphViz(lg::LabeledSimpleGraph, locs=Layout(:spring); kwargs...)
    return GraphViz(; locs=render_locs(lg.graph, locs), edges=[(src(e), dst(e)) for e in edges(lg.graph)], texts = string.([lg.v2l[i] for i in 1:nv(lg)]), kwargs...)
end

function LuxorGraphPlot.show_graph(lg::LabeledSimpleGraph, locs=Layout(:spring); kwargs...)
    gviz = GraphViz(; locs=render_locs(lg.graph, locs), edges=[(src(e), dst(e)) for e in edges(lg.graph)], texts = string.([lg.v2l[i] for i in 1:nv(lg)]), kwargs...)
    return show_graph(gviz)
end