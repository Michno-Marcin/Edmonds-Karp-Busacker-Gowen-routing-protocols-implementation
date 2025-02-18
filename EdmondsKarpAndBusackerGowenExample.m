% An example showing the methodology of the Edmonds-Karp algorithm
% (Ford Folkurson with the BFS algorithm for determining shortest paths based on the number of hops)

%% Preparing to execute a script, preliminary cleaning of console, variables, open windows
clear; close all; clc;

%% Assigning appropriate network properties
source  = [1 1 1 2 2 3 3 4 4 5 6 6]; % The beginning of the channel
target_nodes = [2 3 4 3 7 5 7 3 5 7 1 4]; % The end of channel
names = {'A', 'B', 'C', 'D','E','s','t'}; % Names of nodes
throughput = [7 3 10 4 6 2 9 3 6 8 9 9]; % Wages of nodes
cost = [5 6 3 8 8 2 6 8 9 10 5 6]; % Wages of nodes (node distances)

%% Residual network visualization
% Creation of a residual network graph
ResidualGraph = digraph(source,target_nodes,throughput,names);
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight);
% Width of the channel on the graph
GPlotResidual = plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight, ...
    'LineWidth',ResidualLWidths); title('ResidualGraph');
GPlotResidual.MarkerSize = 4; % Resizing nodes for graph clarity
GPlotResidual.NodeColor='black'; % Changing the color of nodes for graph clarity
GPlotResidual.EdgeColor='blue'; % Changing the color of channels for graph clarity
% We can also visually show on the graph the ratio of the respective distances between nodes
layout(GPlotResidual,'force','WeightEffect','direct');

%% Cost network visualisation
CostGraph = digraph(source,target_nodes,cost,names); % Creation of a cost network graph
CostLWidths = 2*CostGraph.Edges.Weight/max(CostGraph.Edges.Weight); % Channel width on the graph
GPlotCost = plot(CostGraph,'EdgeLabel',CostGraph.Edges.Weight,'LineWidth',CostLWidths);
% Channel width on the graph
title('CostGraph');
GPlotCost.MarkerSize = 4; % Resizing nodes for graph clarity
GPlotCost.NodeColor='black'; % Changing the color of nodes for graph clarity
GPlotCost.EdgeColor='blue'; % Changing the color of channels for graph clarity
% We can also visually show on the graph the ratio of the respective distances between nodes
layout(GPlotCost,'force','WeightEffect','direct');

%% Example data matrix for a residual network
% AdjandencyMatrix = full(adjacency(ResidualGraph)) % Adjacency matrix of the given graph
% AdWeMatrix = adjacency(ResidualGraph,‘weighted’);
% AdjadencyWeightMatrix = full(AdWeMatrix) % Weighted (adjacency) matrix of the given graph
% IMatrix = incidence(ResidualGraph);
% IncidenceMatrix = full(IMatrix) % Incidence matrix of the given graph

%% An example of the Ford-Folkurson algorithm

% We will use graphs created at the beginning.
% In the first step of the algorithm, we reset the channels of the flow network,
% and look for the shortest extending path (of residual network) from source s to target t,
% taking into account only the number of channels along the way.
FlowGraph = ResidualGraph; FlowGraph.Edges.Weight(:)= 0; NewResidualGraph=ResidualGraph;
NewResidualLWidths=ResidualLWidths;

% Determination of the shortest path using the BFS (‘non-weighted’) method
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
% We mark the found path (on the residual network graph)
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight, ...
    'LineWidth',NewResidualLWidths); title('NewResidualGraph with marked shortest path');
GPlotResidual.MarkerSize = 4; % Resizing nodes for graph clarity
GPlotResidual.NodeColor='black'; % Changing the color of nodes for graph clarity
GPlotResidual.EdgeColor='blue'; % Changing the color of channels for graph clarity
highlight(GPlotResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

% We are now looking for the smallest residual capacity in a given stream
% After finding it, we decrease each residual network channel,
% and we increase the channel of the flow network by a given value (in a given stream)
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% This is flow network with the marked path before increasing the corresponding values
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph before increasing relevant values');
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

StartFlowPathNode = string.empty; EndFlowPathNode = string.empty;
for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i); % Start nodes
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % End nodes
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% This is the flow network graph after the first stage of optimization
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight, 'NodeColor','red', ...
    'EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph after 1 iteration of optimization');
% In order for the following graph to represent a residual network,
% we need to remove the redundant channels (with zero capacity) arising from previous operations
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
L0Widths=NewResidualLWidths==0;
NewResidualLWidths(L0Widths)=mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph before 1 iteration of optimisation');

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
% Channel width on the graph

% This is the residual network graph after the first stage of optimization
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph after 1 iteration of optimization');
% Then we return to the search for further extending paths and similarly we perform further steps
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
highlight(GPlotResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;
% layout(GPlotResidual,'force','WeightEffect','direct')

% This is flow network with the marked path before increasing the corresponding values
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red', ...
    'EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph before 2 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i); % Startowe wêz³y
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % End nodes
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% This is the flow network graph after the second stage of optimization
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph after 2 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% And in order for the following graph to represent a residual network,
% we need to remove the redundant channels (with zero capacity) arising from previous operations
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
ResidualL0Widths=NewResidualLWidths==0;
NewResidualLWidths(ResidualL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph before 2 iterations of optimization');

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
% Width of the channel on the graph

% This is the residual network graph after the second stage of optimization
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph after 2 iterations of optimization');
% layout(GPlotResidual,'force','WeightEffect','direct')

% Similarly in third stage:
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
highlight(GPlotResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% This is the the flow network with the marked path before increasing the corresponding values
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph before 3 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i); % Start nodes
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % End nodes
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% This is flow network graph after the third stage of optimization
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph after 3 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% And in order for the following graph to represent a residual network,
% we need to remove the redundant channels (with zero capacity) arising from previous operations
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
ResidualL0Widths=NewResidualLWidths==0;
NewResidualLWidths(ResidualL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight, 'LineWidth', ...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph before 3 iterations of optimization');

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
% Width of the channel on the graph

% This is the residual network graph after the third stage of optimization
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight, 'LineWidth', ...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph after 3 iterations of optimization');
% layout(GPlotResidual,'force','WeightEffect','direct')

% Fourth stage ...
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
highlight(GPlotResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% This is flow network with the marked path before increasing the corresponding values
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph before 4 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i); % Start nodes
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % End nodes
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% This is flow network graph after the fourth stage of optimization
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph after 4 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% And in order for the following graph to represent a residual network,
% we need to remove the redundant channels (with zero capacity) arising from previous operations
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
ResidualL0Widths=NewResidualLWidths==0;
NewResidualLWidths(ResidualL0Widths) = mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight, 'LineWidth', NewResidualLWidths, ...
    'NodeColor','black','EdgeColor','blue','MarkerSize',4); title('NewResidualGraph');

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
% Width of the channel on the graph

% This is the residual network graph after the fourth stage of optimization
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph after 4 iterations of optimization');
layout(GPlotResidual,'force','WeightEffect','direct')

% Fifth stage
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
% We have reached the stage where we cannot find an extending path.
% The flow cannot be increased any further, so in the end:
% the graph of the flow network looks as follows (after removing the dried up channels):
numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('Fully optimized FlowGraph');
disp('Network has been fully optimized.');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Example of the Busacker-Gowen algorithm for networks with specified costs %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We will use graphs created at the beginning.
% In the first step of the algorithm, we reset the channels of the flow network,
% and look for the shortest extending path (of residual network) from source s to target t,
% taking into account costs/distances.
FlowGraph = ResidualGraph; FlowGraph.Edges.Weight(:)= 0; NewResidualGraph=ResidualGraph;
NewResidualLWidths=ResidualLWidths;

% Determination of the shortest path using the Djikstra method (for positively defined curves)
[ShortestPathOfCostGraph,Length,Edges] = shortestpath(CostGraph,'s','t','Method','positive');
disp([ShortestPathOfCostGraph,Length,Edges]);
GPlotCost = plot(CostGraph,'EdgeLabel',CostGraph.Edges.Weight,'LineWidth',CostLWidths);
title('CostGraph');
GPlotCost.MarkerSize = 4; % Resizing nodes for graph clarity
GPlotCost.NodeColor='black'; % Changing the color of nodes for graph clarity
GPlotCost.EdgeColor='blue'; % Changing the color of channels for graph clarity
layout(GPlotCost,'force','WeightEffect','direct') ;
highlight(GPlotCost,ShortestPathOfCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

% We will show the determined corresponding shortest path from the cost
% network on the residual network graph
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight, ...
    'LineWidth',NewResidualLWidths); title('NewResidualGraph');
GPlotResidual.MarkerSize = 4; % Resizing nodes for graph clarity
GPlotResidual.NodeColor='black'; % Changing the color of nodes for graph clarity
GPlotResidual.EdgeColor='blue'; % Changing the color of channels for graph clarity
highlight(GPlotResidual,ShortestPathOfCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

% We now look for the smallest residual capacity in a given stream
% Once this has been found, we reduce each residual network channel,
% and increase the channel of the flow network by a given value (in a given stream)
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% This is flow network with the marked path before increasing the corresponding values
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph before 1 iteration of optimization');
highlight(GPlotFlow,ShortestPathOfCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfCostGraph(i); % Start nodes
    EndFlowPathNode(i)=ShortestPathOfCostGraph(i+1); % End nodes
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% This is flow network graph after the first stage of optimization
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight, 'NodeColor','red', ...
    'EdgeColor','green','MarkerSize',4,'LineWidth',2); title('FlowGraph');
% And in order for the following graph to represent a residual network,
% we need to remove the redundant channels (with zero capacity) arising from previous operations
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
ResidualL0Widths=NewResidualLWidths==0;
NewResidualLWidths(ResidualL0Widths) = mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph before 1 iteration of optimization');

% We must also take into account that determined shortest routes
% later must not contain the dried up channels of the residual network graph.
% For simplicity, we will create an auxiliary graph based on the cost graph,
% but without the aforementioned channels. Then, in one go we will remove
% the corresponding channels in the residual and auxiliary graphs.
SmallerCostGraph = digraph(source,target_nodes,cost,names); % Creation of an auxiliary (cost) graph

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (We must also remove all parameters of an edge from the relevant lists)
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight);
% Channels width on the graph

% This is the residual network graph after the first stage of optimization
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph');
% This is the auxiliary network graph after the first stage of optimization
plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,...
    'LineWidth',SmallerCostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('SmallerCostGraph after 1 iteration of optimization');

% Then we return to the search for further extending paths and
% continue in the same way as in the previous step of the of the algorithm,
% but this time we use an auxiliary graph to determine the paths
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth', ...
    SmallerCostLWidths);
title('SmallerCostGraph');
GPlotSmallerCost.MarkerSize = 4; % Resizing nodes for graph clarity
GPlotSmallerCost.NodeColor='black'; % Changing the color of nodes for graph clarity
GPlotSmallerCost.EdgeColor='blue'; % Changing the color of channels for graph clarity
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% This is flow network with the marked path before increasing the corresponding values
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red', ...
    'EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph before 2 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfSmallerCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i); % Start nodes
    EndFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i+1); % End nodes
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% This is the flow network graph after the second stage of optimization
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph after 2 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% And in order for the following graph to represent a residual network,
% we need to remove the redundant channels (with zero capacity) arising from previous operations
ResidualL0Widths = NewResidualLWidths==0;
NewResidualLWidths(ResidualL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph before 2 iterations of optimization');

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (We must also remove all parameters of an edge from the relevant lists)
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight);
% Channel width on the graph

% This is the residual network graph after the second stage of optimization
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph after 2 iterations of optimization');
% This is the auxiliary network graph after the second stage of optimization
plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,...
    'LineWidth',SmallerCostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('SmallerCostGraph after 2 iterations of optimization');

% Similarly in third stage:
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel', ...
    SmallerCostGraph.Edges.Weight,'LineWidth',SmallerCostLWidths);
title('SmallerCostGraph before 3 iterations of optimization');
GPlotSmallerCost.MarkerSize = 4; % Resizing nodes for graph clarity
GPlotSmallerCost.NodeColor='black'; % Changing the color of nodes for graph clarity
GPlotSmallerCost.EdgeColor='blue'; % Changing the color of channels for graph clarity
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% This is the flow network with the marked path before increasing the corresponding values
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph before 3 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfSmallerCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i); % Start nodes
    EndFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i+1); % End nodes
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% This is the flow network graph after the third stage of optimization
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph after 3 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% And in order for the following graph to represent a residual network,
% we need to remove the redundant channels (with zero capacity) arising from previous operations
ResidualL0Widths=NewResidualLWidths==0;
NewResidualLWidths(ResidualL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph before 3 iterations of optimization');

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (We must also remove all parameters of an edge from the relevant lists)
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight);
% Channel widths on the figures

% This is the residual network graph after the third stage of optimization
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph after 3 iterations of optimization');
layout(GPlotResidual,'force','WeightEffect','direct')

% Stage fourth ...
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth', ...
    SmallerCostLWidths); % Rysunek grafu
title('GPlotSmallerCost before 4 iterations of optimization');
GPlotSmallerCost.MarkerSize = 4; % Resizing nodes for graph clarity
GPlotSmallerCost.NodeColor='black'; % Changing the color of nodes for graph clarity
GPlotSmallerCost.EdgeColor='blue'; % Changing the color of channels for graph clarity
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% This is the flow network with the marked path before increasing the corresponding values
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph before 4 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfSmallerCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i); % Start nodes
    EndFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i+1); % End nodes
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% This is the flow network graph after the fourth stage of optimization
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph after 4 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% And in order for the following graph to represent a residual network,
% we need to remove the redundant channels (with zero capacity) arising from previous operations
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
ResidualL0Widths=NewResidualLWidths==0;
NewResidualLWidths(ResidualL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph before 4 iterations of optimization');

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (We must also remove all parameters of an edge from the relevant lists)
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight);
% Channel width on the graph

% This is the residual network graph after the fourth stage of optimization
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph after 4 iterations of optimization');

% Stage fifth
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth', ...
    SmallerCostLWidths); % Rysunek grafu
title('SmallerCostGraph before 5 iterations of optimization');
GPlotSmallerCost.MarkerSize = 4; % Resizing nodes for graph clarity
GPlotSmallerCost.NodeColor='black'; % Changing the color of nodes for graph clarity
GPlotSmallerCost.EdgeColor='blue'; % Changing the color of channels for graph clarity
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% This is the flow network with the marked path before increasing the corresponding values
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph before 5 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfSmallerCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i); % Start nodes
    EndFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i+1); % End nodes
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% This is the flow network graph after the fifth stage of optimization
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph after 5 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% And in order for the following graph to represent a residual network,
% we need to remove the redundant channels (with zero capacity) arising from previous operations
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
ResidualL0Widths=NewResidualLWidths==0;
NewResidualLWidths(ResidualL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph before 5 iterations of optimization');

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (We must also remove all parameters of an edge from the relevant lists)
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight);
% Channel width on the graph

% This is the residual network graph after the fifth stage of optimization
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph after 5 iterations of optimization');

% Stage sixth ...
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);
% We have reached the stage where we cannot find an extending path.
% The flow cannot be increased any further, so in the end:
% the graph of the flow network looks as follows (after removing the dried up channels):
numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('Fully optimized FlowGraph');
disp('Network has been fully optimized.');
