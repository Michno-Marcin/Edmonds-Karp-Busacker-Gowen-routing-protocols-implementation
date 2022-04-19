%% Przyk³adowe zad. pokazuj¹ce schemat dzia³ania algorytmu Edmondsa-Karpa 
% W tym zastosowanie metody superŸróde³, superujœæ na wiêksz¹ skalê

%% Przygotowanie do wykonania skryptu, wstêpne czyszczenie konsoli, zmiennych, otwartych okien
clear; close all; clc;

%% Przypisanie odpowiednich w³aœciwoœci sieci
AmountOfNodes=int16.empty;
while isempty(AmountOfNodes) 
    AmountOfNodes = input(' Enter number of nodes: '); % np. 30; % Liczba przyjêtych wêz³ów
    while AmountOfNodes<=0 
        AmountOfNodes = input(' Enter proper number of nodes: ');
    end
end
AmountOfLinks=int16.empty;
while isempty(AmountOfLinks) 
    AmountOfLinks = input(' Enter number of links: ');% np. 130; % Liczba przyjêtych kana³ów
    while AmountOfLinks<=0
        AmountOfLinks = input(' Enter proper number of links: ');
    end
end
% Macierz wag wszystkich kanalow z  losowymi wartoœciami z zakresu: 1-(liczba wêz³ów)
throughput = round(99*rand(1,AmountOfLinks))+1;
cost = round(99*rand(1,AmountOfLinks))+1; % Wagi wêz³ów (odleg³oœci wêz³ów)
% Pocz¹tek i koniec kana³ów wszystkich kanalów (Utworzenie kana³ów) z zakresu: 1-(liczba wêz³ów)
source=round((AmountOfNodes-1)*rand(1,AmountOfLinks))+1;
target_nodes=round((AmountOfNodes-1)*rand(1,AmountOfLinks))+1;

% Nazwy wêz³ów utworzymy w pêtli poprzez stworzenie 'Nr?", gdzie ? to numer wêz³a
names=string.empty(0,AmountOfNodes);
 for x=AmountOfNodes:-1:1
     NodeIndex=convertCharsToStrings(['Nr',num2str(x)]);
     names(x)=NodeIndex;
 end 
 
% Utworzenie grafu sieci rezydualnej, ignorujemy "samopêtle"
ResidualGraph = digraph(source,target_nodes,throughput,names,'omitselfloops'); 
% Usuwamy wielokrotne kana³y, jeœli takie istniej¹ i zast¹piamy pojedynczymi
if ismultigraph(ResidualGraph)
    ResidualGraph = simplify(ResidualGraph,'sum'); 
end

% Przed rozpoczêciem algorytmu szukania œcie¿ek musimy wybraæ Ÿród³a oraz
% ujœcia danej sieci w celu jej optymalizacji. Z grafu wiemy, ¿e :
% AmountOfNodes % <-- iloœæ wêz³ów wynosi:
% AmountOfLinks % <-- iloœæ kana³ów wynosi:
% names % <-- nazwy wygl¹daj¹ nastêpuj¹co
% Wybierzemy losowe dla Ÿróde³ np. 5 wêz³ów, oraz dla ujœæ i oczekiwany przep³yw pomiêdzy nimi.
AmountOfSources=int16.empty;
while isempty(AmountOfSources) 
    AmountOfSources = input(' Enter number of sources: '); % np. 5; 
    while ~(AmountOfSources<=AmountOfNodes)
    disp("Amount of sources must be smaller than amount of nodes !"); 
    AmountOfSources = input('Enter proper number of sources again: '); % np. 5; 
    end
    while (AmountOfSources<0)
    disp("Amount of sources must a positive number !"); 
    AmountOfSources = input('Enter proper number of targets again: '); % np. 5; 
    end
end
AmountOfTargets=int16.empty;
while isempty(AmountOfTargets) 
    AmountOfTargets = input(' Enter number of targets: '); % np. 5; 
    while ~(AmountOfTargets<=AmountOfNodes)
    disp("Amount of targets must be smaller than amount of nodes !"); 
    AmountOfTargets = input('Enter proper number of targets again: '); % np. 5; 
    end
    while (AmountOfTargets<0)
    disp("Amount of targets must a positive number !"); 
    AmountOfTargets = input('Enter proper number of targets again: '); % np. 5; 
    end
end
WantedFlow=int16.empty;
while isempty(WantedFlow) 
    WantedFlow = input(' Enter amount of flow you want to add between this nodes: '); % np. 5; 
    while (WantedFlow<=0)
        WantedFlow = input(' Amount of flow must be a positive number ! Enter proper amount of flow you want to add between this nodes: '); % np. 5; 
    end
end
ChosenSources = randperm(AmountOfNodes,AmountOfSources); % losowe Ÿród³a z zakresu: 1-(liczba wêz³ów) bez powtórzeñ
ChosenTargets = randperm(AmountOfNodes,AmountOfTargets); % losowe ujœcia z zakresu: 1-(liczba wêz³ów) bez powtórzeñ

%% Dzia³anie algorytmu Forda-Folkursona

% Macierz wagowa (s¹siedztwa) danego grafu rezydualnego:
AdjadencyWeightMatrix = full(adjacency(ResidualGraph,'weighted')) ; 

% Dodamy superŸród³o, superujœcie oraz podpiszemy je
NamesForNewNodes = {'SuperSource', 'SuperTarget'};
NewResidualgraph = addnode(ResidualGraph,2);
NewResidualgraph.Nodes.Name(size(NewResidualgraph.Nodes,1)-1:end) = NamesForNewNodes;

% Dodamy odpowiednie kana³y i ich przepustowoœci rezydualne dla superŸród³a
NewResidualgraph = addedge(NewResidualgraph, {'SuperSource'},NewResidualgraph.Nodes.Name(ChosenSources), ...
    sum(AdjadencyWeightMatrix(ChosenSources,:),2)); % <-- przepustowoœci rezydualne kolejnych "³¹czników"

% Dodamy odpowiednie kana³y i ich przepustowoœci rezydualne dla superujœcia
NewResidualgraph = addedge(NewResidualgraph, NewResidualgraph.Nodes.Name(ChosenTargets),{'SuperTarget'}, ...
    sum(AdjadencyWeightMatrix(:,ChosenTargets))); % <-- przepustowoœci rezydualne kolejnych "³¹czników"

% % Ewentualny rysunek
% NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
% L0Widths=find(NewResidualLWidths==0);
% NewResidualgraph=rmedge(NewResidualgraph,L0Widths); NewResidualLWidths(L0Widths)=[];
% if (~isempty(NewResidualLWidths)) 
%     plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
%         NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
% end

% Na zmodyfikowanym grafie mo¿emy azcz¹æ szukaæ ju¿ œcie¿ek roszerzaj¹cych 
% miêdzy superŸród³em, a superujœciem korzystaj¹c z algorytmu Edmondsa-Karpa.

% W pierwszym kroku zadania zerujemy kana³y sieci przep³ywowej, oraz szukamy najkrótszej œcie¿ki rozszerzaj¹cej 
% (sieci rezydualnej) ze superŸród³a do superujœcia, bior¹c pod uwagê jedynie iloœæ kana³ów po drodze
FlowGraph = NewResidualgraph; FlowGraph.Edges.Weight(:)= 0;

% Nastêpnie poszukujemy œcie¿ek rozszerzaj¹cych (jeœli istniej¹) dla
% tego samego wêz³a pocz¹tkowego i koñcowego (i,j) oraz analogicznie
% wykonujemy dalsze czynnoœci. Jeœli nie mo¿emy ich znaleŸæ, wyœwietlimy zoptymalizowany graf.
iteration=0;
AddedFlow=0;
UnusedNetworkFlow=double.empty;
while AddedFlow <= WantedFlow
    if AddedFlow == WantedFlow
        NewResidualgraph=rmnode(NewResidualgraph,[{'SuperSource'},{'SuperTarget'}]);
        FlowGraph=rmnode(FlowGraph,[{'SuperSource'},{'SuperTarget'}]);
        fprintf('\t Network graph has been optimised in: %d iterations with amount of new flow: %d. \n \t',iteration ,WantedFlow);
        if (~isempty(UnusedNetworkFlow))
            disp([' Network graph has been optimised in: ',  num2str((100 - UnusedNetworkFlow(end)/UnusedNetworkFlow(1)*100)), ' %'  ]);
        else 
            disp(' Network graph has not been optimised as no flow was chosen.');
        end
        break;
    end
    [ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualgraph,'SuperSource','SuperTarget','Method','unweighted');
    UnusedNetworkFlow(iteration+1)=sum(sum(full(adjacency(NewResidualgraph,'weighted'))));
    disp(['How much can be optimised in ',num2str(iteration+1),' iteration: ', num2str(UnusedNetworkFlow(iteration+1)),'.']);
    if Length == Inf
        NewResidualgraph=rmnode(NewResidualgraph,[{'SuperSource'},{'SuperTarget'}]);
        FlowGraph=rmnode(FlowGraph,[{'SuperSource'},{'SuperTarget'}]);
        fprintf('\t This network can not be optimised with chosen amount of flow. Not enough extension paths found in: %d iterations.',iteration);
        fprintf('\n \t Reached new flow is: %d but needed was: %d. \n', AddedFlow,WantedFlow);
        break;
    else
        iteration=iteration+1;
        MinimumResidualCapacity = min(NewResidualgraph.Edges.Weight(Edges));
        if MinimumResidualCapacity <= (WantedFlow - AddedFlow)
            NewFlow = MinimumResidualCapacity;
        else
            NewFlow = WantedFlow - AddedFlow;
        end
        AddedFlow = AddedFlow + NewFlow;
        NewResidualgraph.Edges.Weight(Edges)= NewResidualgraph.Edges.Weight(Edges) - NewFlow;
       
        % Dla sieci przep³ywowej identyfikatory odpowiednich kana³ów nie bêd¹ identyczne z powodu zmiany kierunku œcie¿ki. 
        % Utworzymy wiêc na niej wielokrotne krawêdzie, a nastêpnie uproœcimy je tworz¹c ich sumê.
        
        % Zwiêkszamy odpowiednie wartoœci
        for i=1:(length(ShortestPathOfBuiltGraph)-1)
            FlowGraph = addedge(FlowGraph, ShortestPathOfBuiltGraph(i),ShortestPathOfBuiltGraph(i+1), NewFlow);
            FlowGraph = simplify(FlowGraph,'sum');
        end
        
        % Usuwamy kana³y zbêdne(z zerow¹ przepustowoœci¹) powsta³e w wyniku poprzednich operacji
        NewResidualgraph = rmedge(NewResidualgraph,find(NewResidualgraph.Edges.Weight==0));   
    end
end

% Doszliœmy do etapu, w którym nie mo¿emy znaleŸæ œcie¿ki rozszerzaj¹cej.
% Przep³yw nie mo¿e byæ ju¿ bardziej zwiêkszony, a wiêc poka¿emy otrzymane rezultaty 
% (po usuniêciu kana³ów wyschniêtych w grafie rezydualnym, przep³ywu, pomocniczym):
numbers = find(ResidualGraph.Edges.Weight==0);
ResidualGraph=rmedge(ResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight); % Szerokoœæ kana³u na rysunku

numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
FlowLWidths = 2*FlowGraph.Edges.Weight/max(FlowGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku

% Otrzymane rezultaty
tiledlayout(1,2); 
nexttile;
if (isempty(FlowLWidths)) 
    FlowLWidths=1;
end
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'LineWidth',FlowLWidths,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',5);
nexttile;
if (~isempty(NewResidualLWidths)) 
    plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
        NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',5);
end

%% Dzia³anie algorytmu Busackera-Gowena

% Skorzystamy z utworzonych na pocz¹tku grafów i wizualizacji, oraz utworzymy nowy graf sieci kosztów
CostGraph = digraph(source,target_nodes,cost,names,'omitselfloops'); % Utworzenie grafu sieci kosztów
% Usuwamy wielokrotne kana³y, jeœli takie istniej¹ i zast¹piamy pojedynczymi
if ismultigraph(CostGraph)
    CostGraph = simplify(CostGraph,'sum'); 
    % Waga pozostawionej krawêdzi równa jest sumie wag krawêdzi w niej zawartych
end

% Macierz wagowa (s¹siedztwa) danego grafu rezydualnego:
AdjadencyWeightMatrix = full(adjacency(ResidualGraph,'weighted')) ; 

% Dodamy superŸród³o, superujœcie oraz podpiszemy je. 
% Przyjmiemy umownie, ¿e koszt kana³ów wychodz¹cych/wchodz¹cych z nimi powi¹zanymi wynosi 0.
ResidualGraph = addnode(ResidualGraph,2);
NewCostgraph = addnode(CostGraph,2);
ResidualGraph.Nodes.Name(size(ResidualGraph.Nodes,1)-1:end) = {'SuperSource', 'SuperTarget'};
NewCostgraph.Nodes.Name(size(NewCostgraph.Nodes,1)-1:end) = {'SuperSource', 'SuperTarget'};

CostOfSuperSources = zeros(1,AmountOfSources); 
CostOfSuperTargets = zeros(1,AmountOfTargets);
% Dodamy odpowiednie kana³y i ich przepustowoœci rezydualne dla superŸród³a w grafie sieci rezydualnej i kosztów
NewResidualgraph = addedge(ResidualGraph, {'SuperSource'},ResidualGraph.Nodes.Name(ChosenSources), ...
    sum(AdjadencyWeightMatrix(ChosenSources,:),2)); % <-- przepustowoœci rezydualne kolejnych "³¹czników"
NewCostgraph = addedge(NewCostgraph, {'SuperSource'},NewCostgraph.Nodes.Name(ChosenSources),CostOfSuperSources); % <-- koszty "³¹czników"

% Dodamy odpowiednie kana³y i ich przepustowoœci rezydualne dla superujœcia
NewResidualgraph = addedge(NewResidualgraph, NewResidualgraph.Nodes.Name(ChosenTargets),{'SuperTarget'}, ...
    sum(AdjadencyWeightMatrix(:,ChosenTargets))); % <-- przepustowoœci rezydualne kolejnych "³¹czników"
NewCostgraph = addedge(NewCostgraph, NewCostgraph.Nodes.Name(ChosenTargets),{'SuperTarget'},CostOfSuperTargets); % <-- koszty "³¹czników"
% 
% % Ewentualna wizualizacja zmodyfikowanych grafów sieci kosztów i grafu sieci rezydualnej
% NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
% L0Widths=find(NewResidualLWidths==0);
% NewResidualLWidths(L0Widths)= mean(NewResidualgraph.Edges.Weight)/sum(NewResidualgraph.Edges.Weight);
% plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
%     NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
% 
% CostLWidths = 2*NewCostgraph.Edges.Weight/max(NewCostgraph.Edges.Weight);
% CostL0Widths=find(CostLWidths==0);
% CostLWidths(CostL0Widths)= mean(NewCostgraph.Edges.Weight)/sum(NewCostgraph.Edges.Weight);
% plot(NewCostgraph,'EdgeLabel',NewCostgraph.Edges.Weight,'LineWidth',...
%     CostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Na zmodyfikowanym grafie mo¿emy zacz¹æ szukaæ ju¿ œcie¿ek roszerzaj¹cych 
% miêdzy superŸród³em, a superujœciem korzystaj¹c z algorytmu Busackera-Gowena.

% W pierwszym kroku zadania zerujemy kana³y sieci przep³ywowej, oraz szukamy najkrótszej œcie¿ki rozszerzaj¹cej 
% (sieci rezydualnej) ze superŸród³a do superujœcia, bior¹c pod uwagê jedynie iloœæ kana³ów po drodze
FlowGraph = NewResidualgraph; FlowGraph.Edges.Weight(:)= 0;

% Musimy uwzglêdniæ tak¿e, ¿e wyznaczone póŸniej najkrótsze trasy nie mog¹ zawieraæ 
% kana³ów uschniêtych grafu sieci rezydualnej. Dla uproszczenia utworzymy pomocniczy graf
% na podstawie grafu kosztów, jednak bez wspomnianych kana³ów. Nastêpnie za jednym
% razem usuniemy wiêc odpowiednie kana³y w grafie rezydualnym i pomocniczym
SmallerCostGraph = NewCostgraph; % Utworzenie pomocniczego grafu (kosztów)

% Nastêpnie wracamy do poszukiwania dalszych œcie¿ek rozszerzaj¹cych (jeœli istniej¹) dla
% tego samego wêz³a pocz¹tkowego i koñcowego (i,j) oraz analogicznie
% wykonujemy dalsze czynnoœci. Jeœli nie mo¿emy ich znaleŸæ, wyœwietlimy
% zoptymalizowany graf.

iteration=0;
AddedFlow=0;
CostOfNewFlow=0;
while AddedFlow <= WantedFlow
    if AddedFlow == WantedFlow
        NewResidualgraph=rmnode(NewResidualgraph,[{'SuperSource'},{'SuperTarget'}]);
        FlowGraph=rmnode(FlowGraph,[{'SuperSource'},{'SuperTarget'}]);
        SmallerCostGraph=rmnode(SmallerCostGraph,[{'SuperSource'},{'SuperTarget'}]);
        fprintf('\t Network graph has been optimised in: %d iterations with amount of new flow: %d. Cost of new flow is: %d. \n \t',...
            iteration ,WantedFlow,CostOfNewFlow);
        disp([' Network graph has been optimised in: ',  num2str((100 - UnusedNetworkFlow(end)/UnusedNetworkFlow(1)*100)), ' %'  ]);
        break;
    end
    [ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(SmallerCostGraph,'SuperSource','SuperTarget','Method','positive');
    UnusedNetworkFlow(iteration+1) = sum(sum(full(adjacency(NewResidualgraph,'weighted'))));
    disp(['How much can be optimised in ',num2str(iteration+1),' iteration: ', num2str(UnusedNetworkFlow(iteration+1)),'.']);
    if Length == Inf
        NewResidualgraph=rmnode(NewResidualgraph,[{'SuperSource'},{'SuperTarget'}]);
        FlowGraph=rmnode(FlowGraph,[{'SuperSource'},{'SuperTarget'}]);
        SmallerCostGraph=rmnode(SmallerCostGraph,[{'SuperSource'},{'SuperTarget'}]);
        fprintf('\t This network can not be optimised with chosen amount of flow. Not enough extension paths found in: %d iterations.',iteration);
        fprintf('\n \t Reached new flow is: %d but needed was: %d. Cost of reached flow is: %d. \n', AddedFlow,WantedFlow,CostOfNewFlow);
        break;
    else
        iteration=iteration+1;
        MinimumResidualCapacity = min(NewResidualgraph.Edges.Weight(Edges));
        if MinimumResidualCapacity <= (WantedFlow - AddedFlow)
            NewFlow = MinimumResidualCapacity;
        else
            NewFlow = WantedFlow - AddedFlow;
        end
        AddedFlow = AddedFlow + NewFlow;
        CostOfNewFlow = CostOfNewFlow + sum(NewFlow * SmallerCostGraph.Edges.Weight(Edges));
        NewResidualgraph.Edges.Weight(Edges)= NewResidualgraph.Edges.Weight(Edges) - NewFlow;
       
        % Dla sieci przep³ywowej identyfikatory odpowiednich kana³ów nie bêd¹ identyczne z powodu zmiany kierunku œcie¿ki. 
        % Utworzymy wiêc na niej wielokrotne krawêdzie, a nastêpnie uproœcimy je tworz¹c ich sumê.
        
        % Zwiêkszamy odpowiednie wartoœci
        for i=1:(length(ShortestPathOfBuiltGraph)-1)
            FlowGraph = addedge(FlowGraph, ShortestPathOfBuiltGraph(i),ShortestPathOfBuiltGraph(i+1), NewFlow);
            FlowGraph = simplify(FlowGraph,'sum');
        end
        
        % Usuwamy kana³y zbêdne(z zerow¹ przepustowoœci¹) powsta³e w wyniku poprzednich operacji
        SmallerCostGraph = rmedge(SmallerCostGraph,find(NewResidualgraph.Edges.Weight==0));  
        NewResidualgraph = rmedge(NewResidualgraph,find(NewResidualgraph.Edges.Weight==0));   
    end
end

% Doszliœmy do etapu, w którym nie mo¿emy znaleŸæ œcie¿ki rozszerzaj¹cej.
% Przep³yw nie mo¿e byæ ju¿ bardziej zwiêkszony, a wiêc poka¿emy otrzymnae rezultaty 
%(po usuniêciu kana³ów wyschniêtych w grafie rezydualnym, przep³ywu, pomocniczym):
numbers = find(ResidualGraph.Edges.Weight==0);
ResidualGraph=rmedge(ResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight); % Szerokoœæ kana³u na rysunku

numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
FlowLWidths = 2*FlowGraph.Edges.Weight/max(FlowGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku
CostLWidths = 2*CostGraph.Edges.Weight/max(CostGraph.Edges.Weight);
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight);

% Otrzymane rezultaty
tiledlayout(2,2); 
nexttile;
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'LineWidth',FlowLWidths,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',5);
nexttile;
GPlotNewResidual = plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',5);
nexttile;
GPlotCost = plot(CostGraph,'EdgeLabel',CostGraph.Edges.Weight,'LineWidth',...
    CostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
nexttile;
GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth',...
    SmallerCostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',5);