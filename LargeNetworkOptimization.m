%% Example task showing how the Edmonds-Karp algorithm works
% together with the application of the supersource and supertarget method on a larger scale

%% Preparation for script execution, pre-cleaning of console, variables, open windows
clear; close all; clc;

%% Assigning appropriate network properties
NumberOfNodes=[]; % Number of assumed nodes
while isempty(NumberOfNodes)
    NumberOfNodes = input(' Enter number of nodes: '); % e.g. 30 or 6
    while NumberOfNodes<=0
        NumberOfNodes = input([' Number of nodes must a positive number ! ' ...
            'Enter proper number of nodes: ']);
    end
end
NumberOfLinks=[];
while isempty(NumberOfLinks)
    NumberOfLinks = input(' Enter number of links: '); % e.g. 130; % Number of assumed links
    while NumberOfLinks<=0
        NumberOfLinks = input(' Enter proper number of links: ');
    end
end
% Matrix of weights of all channels with random values in the range: 1-(number of nodes)
throughput = round(99*rand(1,NumberOfLinks))+1;
cost = round(99*rand(1,NumberOfLinks))+1; % Node weights (node distances)
% Start and end of channels of all channels (Channel creation) from the range: 1-(number of nodes)
source=round((NumberOfNodes-1)*rand(1,NumberOfLinks))+1;
target_nodes=round((NumberOfNodes-1)*rand(1,NumberOfLinks))+1;

% Node names will be created in the loop by creating ‘No?’, where ? is the node number
names=string.empty(0,NumberOfNodes);
for x=NumberOfNodes:-1:1
    NodeIndex='No' + string(x);
    names(x)=NodeIndex;
end

% Creation of a residual network graph, we ignore self-loops
ResidualGraph = digraph(source,target_nodes,throughput,names,'omitselfloops');
% Removing multiple channels, if any, and replacing with single channels
if ismultigraph(ResidualGraph)
    ResidualGraph = simplify(ResidualGraph,'sum');
end

% Before starting the pathfinding algorithm, we need to select the sources and
% targets of a given network in order to optimize it. From the graph, we know that :
% NumberOfNodes % <-- the number of nodes is:
% NumberOfLinks % <-- the number of channels is:
% names % <-- the names are as follows
% We will choose random ones for the sources, e.g. 5 nodes,
% and for the targets and the expected flow between them.
NumberOfSources=[];
while isempty(NumberOfSources)
    NumberOfSources = input(' Enter number of sources: '); % e.g. 5 or 2;
    while ~(NumberOfSources<NumberOfNodes) || (NumberOfSources<=0)
        while ~(NumberOfSources<NumberOfNodes)
            fprintf(' Number of sources must be smaller than number of nodes (%d) !\n', NumberOfNodes);
            NumberOfSources = input(' Enter proper number of sources again: '); % e.g. 5 or 2;
        end
        while (NumberOfSources<=0)
            disp(" Number of sources must a positive number !");
            NumberOfSources = input(' Enter proper number of sources again: '); % e.g. 5 or 2;
        end
    end
end
NumberOfTargets=[];
while isempty(NumberOfTargets)
    NumberOfTargets = input(' Enter number of targets: '); % e.g. 5 or 2;
    while NumberOfTargets<=0 || NumberOfTargets>NumberOfNodes-NumberOfSources
        while NumberOfTargets>NumberOfNodes-NumberOfSources
            fprintf([' Number of targets must not be greater than number of nodes ' ...
                'that are not sources (%d) !\n'], NumberOfNodes-NumberOfSources);
            NumberOfTargets = input(' Enter proper number of targets again: '); % e.g. 5 or 2;
        end
        while (NumberOfTargets<=0)
            disp(" Number of targets must a positive number !");
            NumberOfTargets = input(' Enter proper number of targets again: '); % e.g. 5 or 2;
        end
    end
end
WantedFlow=[];
while isempty(WantedFlow)
    WantedFlow = input(' Enter number of flow you want to add between this nodes: '); % e.g. 2000 or 200
    while (WantedFlow<=0)
        WantedFlow = input([' Number of flow must be a positive number ! ' ...
            'Enter proper number of flow you want to add between this nodes: ']); % e.g. 2000 or 200;
    end
end
ChosenSources = randperm(NumberOfNodes,NumberOfSources);
% random sources in the range: 1-(number of nodes) without repetition
ChosenTargets = randperm(NumberOfNodes,NumberOfTargets);
% random targets in the range: 1-(number of nodes) without repetition
while any(ismember(ChosenTargets, ChosenSources))
    ChosenTargets = randperm(NumberOfNodes, NumberOfTargets);
end

%% Ford-Fulkerson Algorithm Process

% Weighted (neighbourhood) matrix of a given residual graph:
AdjadencyWeightMatrix = full(adjacency(ResidualGraph,'weighted'));

% We will add a supersource, a supertarget and label them
NamesForNewNodes = {'SuperSource', 'SuperTarget'};
NewResidualGraph = addnode(ResidualGraph,2);
NewResidualGraph.Nodes.Name(size(NewResidualGraph.Nodes,1)-1:end) = NamesForNewNodes;

% We will add the corresponding channels and their residual capacities for the supersource
NewResidualGraph = addedge(NewResidualGraph, {'SuperSource'}, ...
    NewResidualGraph.Nodes.Name(ChosenSources), ...
    sum(AdjadencyWeightMatrix(ChosenSources,:), 2)); % <-- residual capacities of subsequent ‘connectors’

% We will add the corresponding channels and their residual capacities for the supertarget
NewResidualGraph = addedge(NewResidualGraph, NewResidualGraph.Nodes.Name(ChosenTargets),{'SuperTarget'}, ...
    sum(AdjadencyWeightMatrix(:,ChosenTargets))); % <-- residual capacities of subsequent ‘connectors’

% Optional graph
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
L0Widths=NewResidualLWidths==0;
NewResidualLWidths(L0Widths)=mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
if (numel(NewResidualLWidths)>0)
    plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
        NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
    title('NewResidualGraph');
end

% On the modified graph, we can already start looking for extending paths
% between supersource and supertarget using the Edmonds-Karp algorithm.

% In the first step of the task, we reset the channels of the flow network,
% and look for the shortest extending path (of residual network) from the supersource to the supertarget,
% taking into account only the number of channels along the way.
FlowGraph = NewResidualGraph; FlowGraph.Edges.Weight(:)= 0;

% We then search for extension paths (if any) for the same start and end node (i,j)
% and follow the same steps. If we cannot find them, we display the optimized graph.
iteration=1;
AddedFlow=0;
UnusedNetworkFlow=double.empty;
while AddedFlow <= WantedFlow
    UnusedNetworkFlow(iteration)=sum(sum(full(adjacency(NewResidualGraph,'weighted'))));
    if AddedFlow == WantedFlow
        NewResidualGraph=rmnode(NewResidualGraph,[{'SuperSource'},{'SuperTarget'}]);
        FlowGraph=rmnode(FlowGraph,[{'SuperSource'},{'SuperTarget'}]);
        fprintf(['\t Network graph has been optimized in: %d iterations ' ...
            'with number of new flow: %d \n\t between sources: %s and targets: %s. \n'], ...
            iteration ,WantedFlow, ...
            strjoin(string(ChosenSources),', '), strjoin(string(ChosenTargets),', '));
        fprintf('\t Network graph has been optimized in: %f%%.\n', ...
            100 - UnusedNetworkFlow(end)/UnusedNetworkFlow(1)*100);
        break;
    end
    [ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph, ...
        'SuperSource','SuperTarget','Method','unweighted');
    disp([' How much can be optimized in ',num2str(iteration),' iteration: ', ...
        num2str(UnusedNetworkFlow(iteration)),'.']);
    if Length == Inf
        NewResidualGraph=rmnode(NewResidualGraph,[{'SuperSource'},{'SuperTarget'}]);
        FlowGraph=rmnode(FlowGraph,[{'SuperSource'},{'SuperTarget'}]);
        fprintf(['\t This network can not be optimized with chosen number of flow \n\t between ' ...
            'sources: %s and targets: %s. \n\t Not enough extension paths found in: %d iterations.'], ...
            strjoin(string(ChosenSources),', '), strjoin(string(ChosenTargets),', '), iteration);
        fprintf('\n \t Reached new flow is: %d but needed was: %d. \n', AddedFlow,WantedFlow);
        fprintf('\t Network graph has been optimized in: %f%%.\n', ...
            100 - UnusedNetworkFlow(end)/UnusedNetworkFlow(1)*100);
        break;
    else
        iteration=iteration+1;
        MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges));
        if MinimumResidualCapacity <= (WantedFlow - AddedFlow)
            NewFlow = MinimumResidualCapacity;
        else
            NewFlow = WantedFlow - AddedFlow;
        end
        AddedFlow = AddedFlow + NewFlow;
        NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - NewFlow;

        % For a flow network, the identifiers of the corresponding channels will not be identical
        % because of the change in path direction.
        % We will therefore create multiple edges and then simplify them by creating their sum.

        % Increasing the relevant values
        for i=1:(length(ShortestPathOfBuiltGraph)-1)
            FlowGraph = addedge(FlowGraph, ShortestPathOfBuiltGraph(i), ...
                ShortestPathOfBuiltGraph(i+1), NewFlow);
            FlowGraph = simplify(FlowGraph,'sum');
        end

        % Removing redundant channels (with zero bandwidth) resulting from previous operations
        numbers = find(NewResidualGraph.Edges.Weight==0);
        NewResidualGraph = rmedge(NewResidualGraph,numbers);
    end
end

% We have reached the stage where we cannot find an extending path.
% The flow cannot be increased any further, so we show the results obtained
% (after removing the channels dried up on the residual, flow, auxiliary network graph):
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
% Channel width on the graph

numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
FlowLWidths = 2*FlowGraph.Edges.Weight/max(FlowGraph.Edges.Weight); % Channel width on the graph

% Obtained results
tiledlayout(1,2);
nexttile;
if (isempty(FlowLWidths))
    FlowLWidths=1;
end
if (numel(FlowLWidths)>0)
    plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'LineWidth',FlowLWidths,'NodeColor',...
        'red','EdgeColor','green','MarkerSize',4); title('FlowGraph');
else
    plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
        'red','EdgeColor','green','MarkerSize',4); title('FlowGraph');
end
nexttile;
if (numel(NewResidualLWidths)>0)
    plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
        NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
    title('NewResidualGraph');
end
sgtitle(sprintf('After %d iterations of optimization', iteration));

%% Busacker-Gowen Algorithm Process

% We will use graphs created at the beginning and create a new cost network graph
CostGraph = digraph(source,target_nodes,cost,names,'omitselfloops'); % Creation of a cost network graph
% Removing multiple channels, if any, and replacing with single channels
if ismultigraph(CostGraph)
    CostGraph = simplify(CostGraph,'sum');
    % The weight of an edge left is equal to the sum of the weights of the edges contained therein
end

% Weight (neighbourhood) matrix of a given residual graph:
AdjadencyWeightMatrix = full(adjacency(ResidualGraph,'weighted')) ;

% We will add supersource, supertarget and label them.
% We will conventionally assume that the cost of the outbound/inbound channels associated with them is 0.
NewResidualGraph = addnode(ResidualGraph,2);
NewCostGraph = addnode(CostGraph,2);
NewResidualGraph.Nodes.Name(size(NewResidualGraph.Nodes,1)-1:end) = {'SuperSource', 'SuperTarget'};
NewCostGraph.Nodes.Name(size(NewCostGraph.Nodes,1)-1:end) = {'SuperSource', 'SuperTarget'};

CostOfSuperSources = zeros(1,NumberOfSources);
CostOfSuperTargets = zeros(1,NumberOfTargets);
% We will add the corresponding channels and their residual capacities
% for the supersource on the residual network graph and cost network graph
NewResidualGraph = addedge(NewResidualGraph, {'SuperSource'}, ...
    NewResidualGraph.Nodes.Name(ChosenSources), ...
    sum(AdjadencyWeightMatrix(ChosenSources,:),2)); % <-- residual capacities of subsequent ‘connectors’
NewCostGraph = addedge(NewCostGraph, {'SuperSource'},NewCostGraph.Nodes.Name(ChosenSources), ...
    CostOfSuperSources); % <-- costs of ‘connectors’

% We will add the corresponding channels and their residual capacities for the supertarget
NewResidualGraph = addedge(NewResidualGraph, ...
    NewResidualGraph.Nodes.Name(ChosenTargets),{'SuperTarget'}, ...
    sum(AdjadencyWeightMatrix(:,ChosenTargets))); % <-- residual capacities of subsequent ‘connectors’
NewCostGraph = addedge(NewCostGraph, NewCostGraph.Nodes.Name(ChosenTargets),{'SuperTarget'}, ...
    CostOfSuperTargets); % <-- costs of ‘connectors’

% % Optional visualisation of modified cost network graphs and residual network graphs
% NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
% L0Widths=NewResidualLWidths==0;
% NewResidualLWidths(L0Widths)=mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
% plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
%     NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
%
% CostLWidths = 2*NewCostGraph.Edges.Weight/max(NewCostGraph.Edges.Weight);
% CostL0Widths=CostLWidths==0;
% CostLWidths(CostL0Widths)=mean(NewCostGraph.Edges.Weight)/sum(NewCostGraph.Edges.Weight);
% plot(NewCostGraph,'EdgeLabel',NewCostGraph.Edges.Weight,'LineWidth',...
%     CostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4);
% title('NewCostGraph');

% On the modified graph we can already start looking for extending paths
% between supersource and supertarget using the Busacker-Gowen algorithm.

% In the first step of the task, we reset the channels of the flow network,
% and search for the shortest path extending (residual network) from the supersource to the supertarget,
% taking into account only the number of channels along the way
FlowGraph = NewResidualGraph; FlowGraph.Edges.Weight(:)= 0;

% We must also take into account that the subsequently determined shortest routes must not
% contain of the dried up channels of the residual network graph. For simplicity, we will create
% an auxiliary graph based on the cost graph, but without the aforementioned channels. Then,
% in one go we will remove the corresponding channels on the residual and auxiliary graphs
SmallerCostGraph = NewCostGraph; % Creation of an auxiliary (cost) graph

% We then return to the search for further extending paths (if any) for the of the same
% start and end node (i,j) and similarly we perform further steps.
% If we cannot find them, we display the optimized graph.
iteration=1;
AddedFlow=0;
CostOfNewFlow=0;
while AddedFlow <= WantedFlow
    UnusedNetworkFlow(iteration) = sum(sum(full(adjacency(NewResidualGraph,'weighted'))));
    if AddedFlow == WantedFlow
        NewResidualGraph=rmnode(NewResidualGraph,[{'SuperSource'},{'SuperTarget'}]);
        FlowGraph=rmnode(FlowGraph,[{'SuperSource'},{'SuperTarget'}]);
        SmallerCostGraph=rmnode(SmallerCostGraph,[{'SuperSource'},{'SuperTarget'}]);
        fprintf(['\t Network graph has been optimized in: %d iterations ' ...
            'with number of new flow: %d \n\t between sources: %s and targets: %s. ' ...
            'Cost of new flow is: %d. \n'], iteration, WantedFlow, ...
            strjoin(string(ChosenSources),', '), strjoin(string(ChosenTargets),', '), ...
            CostOfNewFlow);
        fprintf('\t Network graph has been optimized in: %f%%.\n', ...
            100 - UnusedNetworkFlow(end)/UnusedNetworkFlow(1)*100);
        break;
    end
    [ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(SmallerCostGraph, ...
        'SuperSource','SuperTarget','Method','positive');
    disp(['How much can be optimized in ',num2str(iteration),' iteration: ', ...
        num2str(UnusedNetworkFlow(iteration)),'.']);
    if Length == Inf
        NewResidualGraph=rmnode(NewResidualGraph,[{'SuperSource'},{'SuperTarget'}]);
        FlowGraph=rmnode(FlowGraph,[{'SuperSource'},{'SuperTarget'}]);
        SmallerCostGraph=rmnode(SmallerCostGraph,[{'SuperSource'},{'SuperTarget'}]);
        fprintf(['\t This network can not be optimized with chosen number of flow \n\t between ' ...
            'sources: %s and targets: %s. \n\t Not enough extension paths found in: %d iterations.'], ...
            strjoin(string(ChosenSources),', '), strjoin(string(ChosenTargets),', '), iteration);
        fprintf('\n \t Reached new flow is: %d but needed was: %d. Cost of reached flow is: %d. \n', ...
            AddedFlow,WantedFlow,CostOfNewFlow);
        fprintf('\t Network graph has been optimized in: %f%%.\n', ...
            100 - UnusedNetworkFlow(end)/UnusedNetworkFlow(1)*100);
        break;
    else
        iteration=iteration+1;
        MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges));
        if MinimumResidualCapacity <= (WantedFlow - AddedFlow)
            NewFlow = MinimumResidualCapacity;
        else
            NewFlow = WantedFlow - AddedFlow;
        end
        AddedFlow = AddedFlow + NewFlow;
        CostOfNewFlow = CostOfNewFlow + sum(NewFlow * SmallerCostGraph.Edges.Weight(Edges));
        NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - NewFlow;

        % For a flow network, the identifiers of the corresponding channels
        % will not be identical because of the change in path direction.
        % We will therefore create multiple edges and then simplify them by creating their sum.

        % Increasing the relevant values
        for i=1:(length(ShortestPathOfBuiltGraph)-1)
            FlowGraph = addedge(FlowGraph, ShortestPathOfBuiltGraph(i), ...
                ShortestPathOfBuiltGraph(i+1), NewFlow);
            FlowGraph = simplify(FlowGraph,'sum');
        end

        % Removing redundant channels (with zero bandwidth) resulting from previous operations
        numbers = find(NewResidualGraph.Edges.Weight==0);
        SmallerCostGraph = rmedge(SmallerCostGraph,numbers);
        NewResidualGraph = rmedge(NewResidualGraph,numbers);
    end
end

% We have reached the stage where we cannot find an extending path.
% The flow cannot be increased any further, so we will show the results obtained
% (after removing the channels dried up on the residual, flow, auxiliary network graph):
numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
% Channel width on the graph

numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
FlowLWidths = 2*FlowGraph.Edges.Weight/max(FlowGraph.Edges.Weight); % Channel width on the graph
CostLWidths = 2*CostGraph.Edges.Weight/max(CostGraph.Edges.Weight);
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight);

% Obtained results
tiledlayout(2,2);
nexttile;
if (numel(FlowLWidths)>0)
    plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'LineWidth',FlowLWidths,'NodeColor',...
        'red','EdgeColor','green','MarkerSize',4); title('FlowGraph');
else
    plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
        'red','EdgeColor','green','MarkerSize',4); title('FlowGraph');
end
nexttile;
GPlotNewResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4); title('NewResidualGraph');
nexttile;
GPlotCost = plot(CostGraph,'EdgeLabel',CostGraph.Edges.Weight,'LineWidth',...
    CostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4); title('CostGraph');
nexttile;
GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth',...
    SmallerCostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',4); title('SmallerCostGraph');
sgtitle(sprintf('After %d iterations of optimization', iteration));