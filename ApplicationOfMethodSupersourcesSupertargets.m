%% An example showing the methodology of the Edmonds-Karp algorithm
% (Ford Folkurson with the BFS algorithm for determining shortest paths based on the number of hops)
% together with the method of supersources and supertargets

%% Preparing to execute a script, preliminary cleaning of console, variables, open windows
clear; close all; clc;

%% Assigning appropriate network properties
source  = [1 1 1 2 2 3 3 4 4 5 6 6]; % The beginning of the channel
target_nodes = [2 3 4 3 7 5 7 3 5 7 1 4]; % The end of channel
names = {'A', 'B', 'C', 'D','E','F','G'}; % Names of nodes
throughput = [7 3 10 4 6 2 9 3 6 8 9 9]; % Wages of nodes
cost = [5 6 3 8 8 2 6 8 9 10 5 6]; % Wages of nodes (node distances)

%% Residual network visualization
% Creation of a residual network graph
ResidualGraph = digraph(source,target_nodes,throughput,names);
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight);
% Width of the channel on the graph
GPlotResidual = plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight, ...
    'LineWidth',ResidualLWidths);
title('ResidualGraph before 2 iterations of optimization');
GPlotResidual.MarkerSize = 4; % Resizing nodes for graph clarity
GPlotResidual.NodeColor='black'; % Changing the color of nodes for graph clarity
GPlotResidual.EdgeColor='blue'; % Changing the color of channels for graph clarity
% We can also visually show on the graph the ratio of the respective distances between nodes
layout(GPlotResidual,'force','WeightEffect','direct') ;

%% Cost network visualization
CostGraph = digraph(source,target_nodes,cost,names); % Creation of a cost network graph
% Width of the channel on the graph
CostLWidths = 2*CostGraph.Edges.Weight/max(CostGraph.Edges.Weight);
GPlotCost = plot(CostGraph,'EdgeLabel',CostGraph.Edges.Weight,'LineWidth',CostLWidths);
title('CostGraph');
GPlotCost.MarkerSize = 4; % Resizing nodes for graph clarity
GPlotCost.NodeColor='black'; % Changing the color of nodes for graph clarity
GPlotCost.EdgeColor='blue'; % Changing the color of channels for graph clarity
% We can also visually show on the graph the ratio of the respective distances between nodes
layout(GPlotCost,'force','WeightEffect','direct');

%% An example of the Ford-Folkurson algorithm
% We will use graphs created at the beginning.

% Before starting the path-finding algorithm, we need to select the sources
% and targets of a given network in order to optimize it. From the graph, we know that:
% source  = [1 1 2 2 3 3 4 4 5 6 6]; % The beginning of the channel
% target_nodes = [2 3 3 7 5 7 3 5 7 1 4]; % End of the channel
% names = {'A', 'B', 'C', 'D','E','F','G'}; % Names of nodes

% For example, we will choose for sources the nodes: A, B, C
% (first second, third), and for targets the nodes: D, E, F.
Sources_indexes = find(ismember(names, {'A', 'B', 'C'}));
Sources = names(Sources_indexes);
Targets_indexes = find(ismember(names, {'D', 'E', 'F'}));
Targets = names(Targets_indexes);

AdWeMatrix = adjacency(ResidualGraph,'weighted');
AdjadencyWeightMatrix = full(AdWeMatrix); % Weight (adjacency) matrix of a given residual graph
disp(AdjadencyWeightMatrix);

% Weights of outgoing channels of successive sources (sources horizontally)
AdjadencyWeightMatrix(Sources_indexes,:)
sum(AdjadencyWeightMatrix(Sources_indexes,:),"all") % Sum of outgoing weights to all graph sources
% The residual throughput value of the supersource was determined above

AdjadencyWeightMatrix(:,Targets_indexes) % Weights of channels entering successive targets
% Sum of weights going into all graph targets (targets horizontally)
sum(AdjadencyWeightMatrix(:,Targets_indexes),"all")
% The residual throughput value of the supertarget is determined above

% We will add a supersource, supertarget and label them
NamesForNewNodes = {'SuperSource', 'SuperTarget'};
ResidualGraph_super = addnode(ResidualGraph,2);
% ResidualGraph_super.Nodes
ResidualGraph_super.Nodes.Name(size(ResidualGraph_super.Nodes,1)-1:end) = NamesForNewNodes;
% ResidualGraph_super.Nodes

% We will add the appropriate channels and their residual capacities for the supersource
NewResidualGraph = addedge(ResidualGraph_super, {'SuperSource'}, Sources, ...
    sum(AdjadencyWeightMatrix(Sources_indexes,:), 2));
% NewResidualGraph.Edges
% disp(sum(AdjadencyWeightMatrix([1,2,3],:)'));

% We will add the corresponding channels and their residual capacities for the supersource
NewResidualGraph = addedge(NewResidualGraph, Targets,{'SuperTarget'}, ...
    sum(AdjadencyWeightMatrix(:,Targets_indexes))); % Residual capacities of subsequent “connectors”
% NewResidualGraph.Edges

NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
L0Widths=NewResidualLWidths==0;
NewResidualLWidths(L0Widths)= mean(NewResidualGraph.Edges.Weight) ...
    /sum(NewResidualGraph.Edges.Weight);
GPlotNewResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph');
% On the modified graph, we can already start looking for extending paths
% between the supersource and supertarget using the Edmonds-Karp algorithm.

% In the first step of the task, we reset the channels of the flow network,
% and look for the shortest path extending the (residual network) from the supersource
% to the supertarget, considering only the number of channels along the way
FlowGraph = NewResidualGraph; FlowGraph.Edges.Weight(:)= 0;

[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph, ...
    'SuperSource','SuperTarget','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
% We will mark the path found (on the residual network graph)
highlight(GPlotNewResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth', 2,'NodeColor','green');

% We are now looking for the smallest residual capacity in a given stream
% After finding it, we decrease each residual network channel,
% and we increase the flow network channel by a given value (in a given stream)
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% This is flow network with the marked path before increasing the corresponding values
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',4,'LineWidth',2); disp(GPlotFlow);
title('FlowGraph before 1 iteration of optimization');
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

StartFlowPathNode = string.empty; EndFlowPathNode = string.empty;
for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i);
    % This is flow network with the marked path before increasing the corresponding values
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % End nodes
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% This is the flow network graph after the first stage of optimization
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph after 1 iteration of optimization');
% In order for the following graph to represent a residual network,
% we need to remove the redundant channels (with zero capacity) arising from previous operations
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
NewL0Widths=NewResidualLWidths==0;
NewResidualLWidths(NewL0Widths)=mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph before 1 iteration of optimization');

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
% (We also need to remove all parameters of a given edge from the respective lists)
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
% Channel width on the graph

% This is the residual network graph after the first stage of optimization
GPlotNewResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph after 1 iteration of optimization');
% layout(GPlotNewResidual,'force','WeightEffect','direct')

% Then we return to the search for further extending paths and similarly we perform further steps
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph, ...
    'SuperSource','SuperTarget','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
highlight(GPlotNewResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;
% For a flow network, the identifiers of the corresponding channels
% will not be identical because of the change in path direction.
% So we will create multiple edges, and then simplify them by creating their sum.

% This is flow network with the marked path before increasing the corresponding values
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight, ...
    'NodeColor','red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph before 2 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i);
    % This is flow network with the marked path before increasing the corresponding values
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % End nodes
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end

% This is the flow network graph after the second stage of optimization
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph after 2 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% In order for the following graph to represent a residual network,
% we need to remove the redundant channels (with zero capacity) arising from previous operations
NewL0Widths=NewResidualLWidths==0;
NewResidualLWidths(NewL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph before 2 iterations of optimization');

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
% (We also need to remove all parameters of a given edge from the respective lists)
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
% Channel width on the graph

% This is the residual network graph after second stage of optimization
GPlotNewResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph after 2 iterations of optimization');
layout(GPlotNewResidual,'force','WeightEffect','direct')

% Third stage:
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph, ...
    'SuperSource','SuperTarget','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
% We have reached the stage where we can't find an extending path between the supersource and the supertarget.
% The flow cannot be increased any further.
% So we will now remove the artificial 'SuperSource' and artificial 'SuperTarget' from the graph.
NewResidualGraph=rmnode(NewResidualGraph,[{'SuperSource'},{'SuperTarget'}]);

% This is the residual network graph of this network:
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
NewL0Widths=find(NewResidualLWidths==0);
NewResidualLWidths(NewL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4)
title('NewResidualGraph of fully optimized network');

% Finally, the graph of the flow network looks as follows (after removing the dried up channels):
numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph of fully optimized network');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% An example of the Busacker-Gowen algorithm %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for networks with specified costs, using supertargets, supersources

% Before starting the path-finding algorithm, we need to select the sources
% and targets of a given network in order to optimize it. From the graph, we know that:
% source  = [1 1 2 2 3 3 4 4 5 6 6]; % The beginning of the channel
% target_nodes = [2 3 3 7 5 7 3 5 7 1 4]; % End of the channel
% names = {'A', 'B', 'C', 'D','E','F','G'}; % Names of nodes

% We will use graphs created at the beginning.
% For example, we will choose for sources the nodes: A, B, C (first second, third),
% and for targets the nodes: D, E, F.
Sources_indexes = find(ismember(names, {'A', 'B', 'C'}));
Sources = names(Sources_indexes);
Targets_indexes = find(ismember(names, {'D', 'E', 'F'}));
Targets = names(Targets_indexes);

AdWeMatrix = adjacency(ResidualGraph,'weighted');
AdjadencyWeightMatrix = full(AdWeMatrix); % Weight (adjacency) matrix of a given residual graph
disp(AdjadencyWeightMatrix);

% Weights of outgoing channels of successive sources (sources horizontally)
disp(AdjadencyWeightMatrix(Sources_indexes,:)');
sum(AdjadencyWeightMatrix(Sources_indexes,:),"all") % Sum of outgoing weights to all graph sources
% Above, the value of the residual capacity of the supersource was determined

AdjadencyWeightMatrix(:,Targets_indexes) % Weights of channels entering subsequent targets
sum(AdjadencyWeightMatrix(:,Targets_indexes),"all")
% Sum of weights going into all graph targets (targets horizontally)
% Above, the value of the residual throughput of the supertarget was determined

% We will add a supersource, supertarget and label them.
% We will conventionally assume that the cost of outbound/inbound channels associated with them is 0.
NamesForNewNodes = {'SuperSource', 'SuperTarget'};
ResidualGraph = addnode(ResidualGraph,2);
CostGraph_super = addnode(CostGraph,2);
% ResidualGraph_super.Nodes
% CostGraph_super.Nodes
ResidualGraph_super.Nodes.Name(size(ResidualGraph_super.Nodes,1)-1:end) = NamesForNewNodes';
CostGraph_super.Nodes.Name(size(CostGraph_super.Nodes,1)-1:end) = NamesForNewNodes;
% ResidualGraph_super.Nodes.Name
% CostGraph_super.Nodes.Name

% We will add the corresponding channels and their residual capacities
% for the supersource on the graph of residual network and cost
NewResidualGraph = addedge(ResidualGraph_super, {'SuperSource'},Sources, ...
    sum(AdjadencyWeightMatrix(Sources_indexes,:),2));
NewCostGraph = addedge(CostGraph_super, {'SuperSource'},Sources, ...
    [0 0 0]); % <-- costs of 'connectors'
% NewResidualGraph.Edges
% disp(sum(AdjadencyWeightMatrix(Sources_indexes,:)'));
% NewCostGraph.Edges

% We will add the corresponding channels and their residual capacities
% for the supertarget on the graph of residual and cost network
NewResidualGraph = addedge(NewResidualGraph, Targets,{'SuperTarget'}, ...
    sum(AdjadencyWeightMatrix(Sources_indexes,:),2));
NewCostGraph = addedge(NewCostGraph, Targets,{'SuperTarget'}, ...
    [0 0 0]); % <-- costs of “connectors”
% NewResidualGraph.Edges
% NewCostGraph.Edges

% Visualization of modified cost network graphs and residual network graphs
ResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
L0Widths=ResidualLWidths==0;
ResidualLWidths(L0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph');

CostLWidths = 2*NewCostGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
CostL0Widths=find(CostLWidths==0);
CostLWidths(CostL0Widths)= mean(NewCostGraph.Edges.Weight)/sum(NewCostGraph.Edges.Weight);
GPlotNewCost = plot(NewCostGraph,'EdgeLabel',NewCostGraph.Edges.Weight,'LineWidth',...
    CostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewCostGraph before 1 iteration of optimization');

% On the modified graphs, we can already start looking for extending paths
% between the supersource and supertarget using the Busacker-Gowen algorithm

% In the first step of the algorithm, we reset the channels of the flow network, and look
% for the shortest extending path (on a graph with weights specifying the corresponding costs)
% from source s to target t, given the costs/distanceNewResidualgraphs
FlowGraph = NewResidualGraph; FlowGraph.Edges.Weight(:)= 0;

% Determination of the shortest path using Djikstra's method
% from supersource to supertarget based on the cost matrix
[ShortestPathOfNewCostGraph,Length,Edges] = shortestpath(NewCostGraph, ...
    'SuperSource','SuperTarget','Method','positive');
disp([ShortestPathOfNewCostGraph,Length,Edges]);
% We will show the determined corresponding shortest path
% from the cost network to the path on the residual network
GPlotNewResidual = plot(NewResidualGraph,'EdgeLabel', ...
    NewResidualGraph.Edges.Weight,'LineWidth',ResidualLWidths);
title('NewResidualGraph before 1 iteration of optimization');
GPlotNewResidual.MarkerSize = 4; % Resizing nodes for graph clarity
GPlotNewResidual.NodeColor='black'; % Changing the color of nodes for graph clarity
GPlotNewResidual.EdgeColor='blue'; % Changing the color of channels for graph clarity
highlight(GPlotNewResidual,ShortestPathOfNewCostGraph,'EdgeColor','r','LineWidth',2, ...
    'NodeColor','green');

% We are now looking for the smallest residual capacity in a given stream
% After finding it, we decrease each residual network channel,
% and we increase the flow network channel by a given value (in a given stream)
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% This is flow network with the marked path before increasing the corresponding values
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph before 1 iteration of optimization');
highlight(GPlotFlow,ShortestPathOfNewCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfNewCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfNewCostGraph(i);
    % This is flow network with the marked path before increasing the corresponding values
    EndFlowPathNode(i)=ShortestPathOfNewCostGraph(i+1); % End nodes
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% This is the flow network graph after the first stage of optimization
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph after 1 iteration of optimization');
% In order for the following graph to represent a residual network,
% we need to remove the redundant channels (with zero capacity) arising from previous operations
ResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
L0Widths=find(ResidualLWidths==0);
ResidualLWidths(L0Widths)=mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph before 1 iteration of optimization');

% We must also take into account that, with the shortest paths determined later,
% they must not contain dried up channels of the residual network graph.
% For simplicity, we will create an auxiliary graph based on the cost graph,
% but without the mentioned channels. Thus, we will then remove the corresponding channels
% on the residual and auxiliary network graphs in one go
SmallerCostGraph = NewCostGraph; % Creation of an auxiliary (cost) graph

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (We also need to remove all parameters of a given edge from the respective lists)
ResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight);
% Widths of the channel on the graph
SmallerCostL0Widths=SmallerCostLWidths==0;
% Setting minimum channel width on the graph for those with zero cost
SmallerCostLWidths(SmallerCostL0Widths)= mean(SmallerCostGraph.Edges.Weight)/sum(SmallerCostGraph.Edges.Weight);

% This is the the residual network graph after the first stage of optimization
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph after 1 iteration of optimization');

% This is the the auxiliary network graph after the first stage of optimization
GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,...
    'LineWidth',SmallerCostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('SmallerCostGraph after 1 iteration of optimization');
disp(GPlotSmallerCost);
% layout(GPlotSmallerCost,'force','WeightEffect','direct')

% We then return to the search for further extending paths and similarly
% perform further steps, as in the previous step of the algorithm,
% but this time we use an auxiliary graph to determine the paths.
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph, ...
    'SuperSource','SuperTarget','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight, ...
    'LineWidth',SmallerCostLWidths);
title('SmallerCostGraph before 2 iterations of optimization');
GPlotSmallerCost.MarkerSize = 4; % Resizing nodes for graph clarity
GPlotSmallerCost.NodeColor='black'; % Changing the color of nodes for graph clarity
GPlotSmallerCost.EdgeColor='blue'; % Changing the color of channels for graph clarity
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r', ...
    'LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% This is flow network with the marked path before increasing the corresponding values
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight, ...
    'NodeColor','red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph before 2 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfSmallerCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i);
    % This is flow network with the marked path before increasing the corresponding values
    EndFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i+1); % End nodes
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% This is the flow network graph after the second stage of optimization
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph after 2 iterations of optimization');
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% In order for the following graph to represent a residual network,
% we need to remove the redundant channels (with zero capacity) arising from previous operations
ResidualL0Widths=find(ResidualLWidths==0);
ResidualLWidths(ResidualL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
GPlotNewResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph before 2 iterations of optimization');

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (We also need to remove all parameters of a given edge from the respective lists)
ResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight);
% Widths of the channel on the graph
SmallerCostL0Widths=find(SmallerCostLWidths==0);
% Setting minimum channel width on the graph for those with zero cost
SmallerCostLWidths(SmallerCostL0Widths)= mean(SmallerCostGraph.Edges.Weight)/sum(SmallerCostGraph.Edges.Weight);

% This is the the residual network graph after the second stage of optimization
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('NewResidualGraph after 2 iterations of optimization');

% This is the the residual network graph after the second stage of optimization
GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,...
    'LineWidth',SmallerCostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
title('SmallerCostGraph after 2 iterations of optimization');
% layout(GPlotSmallerCost,'force','WeightEffect','direct')

% Stage third
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph, ...
    'SuperSource','SuperTarget','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);
% We have reached the stage where we can't find an extending path between the supersource and the supertarget.
% The flow cannot be increased any further.
% So we will now remove the artificial 'SuperSource' and artificial 'SuperTarget' from the graph.
numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',4,'LineWidth',2);
title('FlowGraph of fully optimized network');
disp('Network has been fully optimized.');
