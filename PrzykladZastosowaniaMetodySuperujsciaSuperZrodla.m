%% Przyk³ad pokazuj¹cy schemat dzia³ania algorytmu Edmondsa-Karpa (Forda Folkursona z algorytmem BFS do wyznaczenia najkrótszych œcie¿ek opartego na liczbie przeskoków)
% razem z metod¹ superŸróde³ i superujœæ

%% Przygotowanie do wykonania skryptu, wstêpne czyszczenie konsoli, zmiennych, otwartych okien
clear; close all; clc;

%% Przypisanie odpowiednich w³aœciwoœci sieci
source  = [1 1 1 2 2 3 3 4 4 5 6 6]; % Pocz¹tek kana³u
target_nodes = [2 3 4 3 7 5 7 3 5 7 1 4]; % Koniec kana³u
names = {'A', 'B', 'C',... % Nazwy wêz³ów
    'D','E','F','G'};
throughput = [7 3 10 4 6 2 9 3 6 8 9 9]; % Wagi wêz³ów
cost = [5 6 3 8 8 2 6 8 9 10 5 6]; % Wagi wêz³ów (odleg³oœci wêz³ów)

%% Wizulalizacja sieci rezydualnej 
ResidualGraph = digraph(source,target_nodes,throughput,names); % Utworzenie grafu sieci rezydualnej
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku
GPlotResidual = plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,'LineWidth',ResidualLWidths); % Rysunek grafu
GPlotResidual.MarkerSize = 7; % Zmiana rozmiaru wêz³ów dla przejrzystoœci rysunku
GPlotResidual.NodeColor='black'; % Zmiana koloru wêz³ów dla przejrzystoœci rysunku
GPlotResidual.EdgeColor='blue'; % Zmiana koloru kana³ów dla przejrzystoœci rysunku
% Mo¿emy na wykresie pokazaæ wizualnie tak¿e stosunek odpowiednich odleg³oœci miêdzy wêz³ami
layout(GPlotResidual,'force','WeightEffect','direct') ;


%% Wizualizacja sieci kosztów
CostGraph = digraph(source,target_nodes,cost,names); % Utworzenie grafu sieci kosztów
CostLWidths = 2*CostGraph.Edges.Weight/max(CostGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku
GPlotCost = plot(CostGraph,'EdgeLabel',CostGraph.Edges.Weight,'LineWidth',CostLWidths); % Rysunek grafu
GPlotCost.MarkerSize = 7; % Zmiana rozmiaru wêz³ów dla przejrzystoœci rysunku
GPlotCost.NodeColor='black'; % Zmiana koloru wêz³ów dla przejrzystoœci rysunku
GPlotCost.EdgeColor='blue'; % Zmiana koloru kana³ów dla przejrzystoœci rysunku
% Mo¿emy na wykresie pokazaæ wizualnie tak¿e stosunek odpowiednich odleg³oœci miêdzy wêz³ami
layout(GPlotCost,'force','WeightEffect','direct'); 

%% Przyk³ad algorytmu Forda-Folkursona
% Skorzystamy z utworzonych na pocz¹tku grafów i wizualizacji

% Przed rozpoczêciem algorytmu szukania œcie¿ek musimy wybraæ Ÿród³a oraz
% ujœcia danej sieci w celu jej optymalizacji. Z grafu wiemy, ¿e :
% source  = [1 1 2 2 3 3 4 4 5 6 6]; % Pocz¹tek kana³u
% target_nodes = [2 3 3 7 5 7 3 5 7 1 4]; % Koniec kana³u
% names = {'A', 'B', 'C', 'D','E','F','G'}; % Nazwy wêz³ów

% Wybierzemy na przyk³ad dla Ÿróde³ wêz³y: A, B, C (pierwszy drugi, trzec),a dla ujœæ wêz³y: D,E,F.
Sources = [1,2,3]; 
SourcesNames = {char(names(Sources))};disp (SourcesNames{1}); % Funkcja char zamieni typ tablicowy na char
Targets = [4,5,6]; 
TargetsNames = {char(names(Targets))}; disp(TargetsNames{1});

AdWeMatrix = adjacency(ResidualGraph,'weighted');
AdjadencyWeightMatrix = full(AdWeMatrix); disp(AdjadencyWeightMatrix); % Macierz wagowa (s¹siedztwa) danego grafu rezydualnego

AdjadencyWeightMatrix(Sources,:) % Wagi kana³ów wychodz¹cych kolejnych Ÿróde³ (Ÿród³a poziomo)
sum(sum(AdjadencyWeightMatrix(Sources,:))) % Suma wag wychodz¹cych do wszystkich Ÿróde³ grafu
% Powy¿ej wyznaczona zosta³¹ wartoœæ przepustowoœci rezydualnej superujŸród³a

AdjadencyWeightMatrix(:,[4,5,6]) % Wagi kana³ów wchodz¹cych do kolejnych ujœæ
sum(sum(AdjadencyWeightMatrix(:,[4,5,6]))) % Suma wag wchodz¹cych do wszystkich ujœæ grafu (ujœcia poziomo)
% Powy¿ej wyznaczona zosta³¹ wartoœæ przepustowoœci rezydualnej superujœcia

% Dodamy superŸród³o, superujœcie oraz podpiszemy je
NamesForNewNodes = {'SuperSource', 'SuperTarget'};
ResidualGraph = addnode(ResidualGraph,2);
% ResidualGraph.Nodes
ResidualGraph.Nodes.Name(size(ResidualGraph.Nodes,1)-1:end) = NamesForNewNodes;
% ResidualGraph.Nodes


% Dodamy odpowiednie kana³y i ich przepustowoœci rezydualne dla superŸród³a
NewResidualgraph = addedge(ResidualGraph, {'SuperSource'},{'A' 'B','C'}, ...
    sum(AdjadencyWeightMatrix([1,2,3],:),2)); % <-- przepustowoœci rezydualne kolejnych "³¹czników"
% NewResidualgraph.Edges
% sum(AdjadencyWeightMatrix([1,2,3],:)');

% Dodamy odpowiednie kana³y i ich przepustowoœci rezydualne dla superujœcia
NewResidualgraph = addedge(NewResidualgraph, {'D' 'E','F'},{'SuperTarget'}, ...
    sum(AdjadencyWeightMatrix(:,[4,5,6]))); % <-- przepustowoœci rezydualne kolejnych "³¹czników"
% NewResidualgraph.Edges

% Rysunek
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
L0Widths=NewResidualLWidths==0;
NewResidualLWidths(L0Widths)= mean(NewResidualgraph.Edges.Weight)/sum(NewResidualgraph.Edges.Weight);
GPlotNewResidual = plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
% Na zmodyfikowanym grafie mo¿emy zacz¹æ szukaæ ju¿ œcie¿ek roszerzaj¹cych 
% miêdzy superŸród³em, a superujœciem korzystaj¹c z algorytmu Edmondsa-Karpa.

% W pierwszym kroku zadania zerujemy kana³y sieci przep³ywowej, oraz szukamy najkrótszej œcie¿ki rozszerzaj¹cej 
% (sieci rezydualnej) ze superŸród³a do superujœcia, bior¹c pod uwagê jedynie iloœæ kana³ów po drodze
FlowGraph = NewResidualgraph; FlowGraph.Edges.Weight(:)= 0;

[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualgraph,'SuperSource','SuperTarget','Method','unweighted'); 
disp([ShortestPathOfBuiltGraph,Length,Edges]);
% Oznaczymy znalezion¹ œcie¿kê (na sieci rezydualnej)
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
highlight(GPlotNewResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',NewResidualLWidths,'NodeColor','green');

% Szukamy teraz najmniejszej przepustowoœci rezydualnej na danym strumieniu
% Po jej znalezieniu zmniejszamy ka¿dy kana³ sieci rezydualnej, 
% oraz zwiêkszamy kana³ sieci przep³ywowej o dan¹ wartoœæ (na danej trasie)
MinimumResidualCapacity = min(NewResidualgraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualgraph.Edges.Weight(Edges)= NewResidualgraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl¹da sieæ przep³ywowa z zaznaczon¹ œcie¿k¹ przed zwiêkszeniem odpowiednich wartoœci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2); disp(GPlotFlow);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

StartFlowPathNode = string.empty; EndFlowPathNode = string.empty;
for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i); % Startowe wêz³y
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % Koñcowe wêz³y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl¹da nasz otrzymany graf sieci przep³ywowej po pierwszym etapie optymalizacji
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
% Aby poni¿szy graf przedstawia³ sieæ rezydualn¹, musimy usun¹æ kana³y
% zbêdne(z zerow¹ przepustowoœci¹) powsta³e w wyniku poprzednich operacji
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
NewL0Widths=NewResidualLWidths==0;
NewResidualLWidths(NewL0Widths)=mean(NewResidualgraph.Edges.Weight)/sum(NewResidualgraph.Edges.Weight);
plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(NewResidualgraph.Edges.Weight==0);
NewResidualgraph=rmedge(NewResidualgraph,numbers);
% (Musimy tak¿e usun¹æ wszystkie parametry danej krawêdzi z odpowiednich list)
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight); % Szerokoœæ kana³u na rysunku

% Tak wygl¹da nasz otrzymany graf sieci rezydualnej po pierwszym etapie
% optymalizacji
GPlotNewResidual = plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
% layout(GPlotResidual,'force','WeightEffect','direct') 


% Nastêpnie wracamy do poszukiwania dalszych œcie¿ek rozszerzaj¹cych i
% analogicznie wykonujemy dalsze czynnoœci
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualgraph,'SuperSource','SuperTarget','Method','unweighted'); 
disp([ShortestPathOfBuiltGraph,Length,Edges]);
highlight(GPlotNewResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');
MinimumResidualCapacity = min(NewResidualgraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualgraph.Edges.Weight(Edges)= NewResidualgraph.Edges.Weight(Edges) - MinimumResidualCapacity;
% Dla sieci przep³ywowej identyfikatory odpowiednich kana³ów nie bêd¹ identyczne z powodu zmiany kierunku œcie¿ki. 
% Utworzymy wiêc na niej wielokrotne krawêdzie, a nastêpnie uproœcimy je tworz¹c ich sumê.

% Tak wygl¹da sieæ przep³ywowa z zaznaczon¹ œciêzk¹ przed zwiêkszeniem odpowiednich wartoœci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
disp(GPlotFlow);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i); % Startowe wêz³y
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % Koñcowe wêz³y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl¹da nasz otrzymany graf sieci przep³ywowej po drugim etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni¿szy graf przedstawia³ sieæ rezydualn¹, musimy usun¹æ kana³y
% zbêdne(z zerow¹ przepustowoœci¹) powsta³e w wyniku poprzednich operacji
NewL0Widths=NewResidualLWidths==0;
NewResidualLWidths(NewL0Widths)= mean(NewResidualgraph.Edges.Weight)/sum(NewResidualgraph.Edges.Weight);
plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(NewResidualgraph.Edges.Weight==0);
NewResidualgraph=rmedge(NewResidualgraph,numbers);
% (Musimy tak¿e usun¹æ wszystkie parametry danej krawêdzi z odpowiednich list)
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight); % Szerokoœæ kana³u na rysunku

% Tak wygl¹da nasz otrzymany graf sieci rezydualnej po drugim etapie
% optymalizacji
GPlotNewResidual = plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
layout(GPlotNewResidual,'force','WeightEffect','direct') 


% Etap trzeci
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualgraph,'SuperSource','SuperTarget','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
% Doszliœmy do etapu, w którym nie mo¿emy znaleŸæ œcie¿ki rozszerzaj¹cej dla superujœcia i superŸród³a.
% Przep³yw nie mo¿e byæ ju¿ bardziej zwiêkszony. usuniemy wiêc teraz
% sztuczne "SuperŸród³o" oraz sztuczne "SuperUjœcie z grafu".
NewResidualgraph=rmnode(NewResidualgraph,[{'SuperSource'},{'SuperTarget'}]);

% Graf rezydualny danej sieci wygl¹da wiêc nastêpuj¹co:
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
NewL0Widths=find(NewResidualLWidths==0);
NewResidualLWidths(NewL0Widths)= mean(NewResidualgraph.Edges.Weight)/sum(NewResidualgraph.Edges.Weight);
plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7)

% Ostatecznie graf sieci przep³ywowej wygl¹da w nastêpuj¹cy sposób (po usuniêciu kana³ów wyschniêtych):
numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',7,'LineWidth',2); disp(GPlotFlow);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Przyk³ad algorytmu Busackera-Gowena dla sieci z okreœlonymi kosztami, z zastosowaniem superujœæ, superŸróde³
% Skorzystamy z utworzonych na pocz¹tku grafów i wizualizacji
% Wybierzemy na przyk³ad dla Ÿróde³ wêz³y: A, B, C (pierwszy drugi, trzeci),a dla ujœæ wêz³y: D,E,F.
SourcesNames={char(names(1)), char(names(2)), char(names(3))}; % Funkcja char zamieni typ tablicowy na char
TargetsNames = {char(names(4)), char(names(5)), char(names(6))};

AdWeMatrix = adjacency(ResidualGraph,'weighted');
AdjadencyWeightMatrix = full(AdWeMatrix); disp(AdjadencyWeightMatrix); disp(AdjadencyWeightMatrix); 
% Macierz wagowa (s¹siedztwa) danego grafu rezydualnego

disp(AdjadencyWeightMatrix([1,2,3],:)'); % Wagi kana³ów wychodz¹cych kolejnych Ÿróde³ (Ÿród³a poziomo)
sum(sum(AdjadencyWeightMatrix([1,2,3],:))) % Suma wag wychodz¹cych do wszystkich Ÿróde³ grafu
% Powy¿ej wyznaczona zosta³¹ wartoœæ przepustowoœci rezydualnej superujŸród³a

AdjadencyWeightMatrix(:,[4,5,6]) % Wagi kana³ów wchodz¹cych do kolejnych ujœæ
sum(sum(AdjadencyWeightMatrix(:,[4,5,6]))) % Suma wag wchodz¹cych do wszystkich ujœæ grafu (ujœcia poziomo)
% Powy¿ej wyznaczona zosta³¹ wartoœæ przepustowoœci rezydualnej superujœcia

% Dodamy superŸród³o, superujœcie oraz podpiszemy je. 
% Przyjmiemy umownie, ¿e koszt kana³ów wychodz¹cych/wchodz¹cych z nimi powi¹zanymi wynosi 0.
NamesForNewNodes = {'SuperSource', 'SuperTarget'};
ResidualGraph = addnode(ResidualGraph,2);
CostGraph = addnode(CostGraph,2);
% ResidualGraph.Nodes
% CostGraph.Nodes
ResidualGraph.Nodes.Name(size(ResidualGraph.Nodes,1)-1:end) = NamesForNewNodes;
CostGraph.Nodes.Name(size(CostGraph.Nodes,1)-1:end) = NamesForNewNodes;
% ResidualGraph.Nodes.Name
% CostGraph.Nodes.Name

% Dodamy odpowiednie kana³y i ich przepustowoœci rezydualne dla superŸród³a w grafie sieci rezydualnej i kosztów
NewResidualgraph = addedge(ResidualGraph, {'SuperSource'},{'A' 'B','C'}, ...
    sum(AdjadencyWeightMatrix([1,2,3],:),2)); % <-- przepustowoœci rezydualne kolejnych "³¹czników"
NewCostgraph = addedge(CostGraph, {'SuperSource'},{'A' 'B','C'},[0 0 0]); % <-- koszty "³¹czników"
% NewResidualgraph.Edges
% sum(AdjadencyWeightMatrix([1,2,3],:)')
% NewCostgraph.Edges

% Dodamy odpowiednie kana³y i ich przepustowoœci rezydualne dla superujœcia w grafie sieci rezydualnej i kosztów
NewResidualgraph = addedge(NewResidualgraph, {'D' 'E','F'},{'SuperTarget'}, ...
    sum(AdjadencyWeightMatrix([1,2,3],:),2)); % <-- przepustowoœci rezydualne kolejnych "³¹czników"
NewCostgraph = addedge(NewCostgraph, {'D' 'E','F'},{'SuperTarget'}, [0 0 0]); % <-- koszty "³¹czników"
% NewResidualgraph.Edges
% NewCostgraph.Edges

% Wizualizacja zmodyfikowanych grafów sieci kosztów i grafu sieci rezydualnej
ResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
L0Widths=ResidualLWidths==0;
ResidualLWidths(L0Widths)= mean(NewResidualgraph.Edges.Weight)/sum(NewResidualgraph.Edges.Weight);
plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
    ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

CostLWidths = 2*NewCostgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
CostL0Widths=find(CostLWidths==0);
CostLWidths(CostL0Widths)= mean(NewCostgraph.Edges.Weight)/sum(NewCostgraph.Edges.Weight);
GPlotNewCost = plot(NewCostgraph,'EdgeLabel',NewCostgraph.Edges.Weight,'LineWidth',...
    CostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Na zmodyfikowanych grafach mo¿emy zacz¹æ szukaæ ju¿ œcie¿ek roszerzaj¹cych 
% miêdzy superŸród³em, a superujœciem korzystaj¹c z algorytmu Busackera-Gowena

% W pierwszym kroku algorytmu zerujemy kana³y sieci przep³ywowej, oraz szukamy najkrótszej œcie¿ki rozszerzaj¹cej 
% (w grafie z wagami okreœlaj¹cymi odpowiednie koszty) ze Ÿród³a s do ujœcia t, bior¹c pod uwagê koszty/odleg³oœci 
FlowGraph = NewResidualgraph; FlowGraph.Edges.Weight(:)= 0;


% Wyznaczenie najkrótszej œcie¿ki metod¹ Djikstry od superŸród³a do superujœæ na podstawie macierzy kosztów
[ShortestPathOfNewCostGraph,Length,Edges] = shortestpath(NewCostgraph,'SuperSource','SuperTarget','Method','positive');
disp([ShortestPathOfNewCostGraph,Length,Edges]);
% Poka¿emy wyznaczon¹ odpowiadaj¹c¹ najkrótszej œcie¿ce z sieci kosztów œcie¿kê w sieci rezydualnej)
GPlotNewResidual = plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',ResidualLWidths); % Rysunek grafu
GPlotNewResidual.MarkerSize = 7; % Zmiana rozmiaru wêz³ów dla przejrzystoœci rysunku
GPlotNewResidual.NodeColor='black'; % Zmiana koloru wêz³ów dla przejrzystoœci rysunku
GPlotNewResidual.EdgeColor='blue'; % Zmiana koloru kana³ów dla przejrzystoœci rysunku
highlight(GPlotNewResidual,ShortestPathOfNewCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

% Szukamy teraz najmniejszej przepustowoœci rezydualnej na danym strumieniu
% Po jej znalezieniu zmniejszamy ka¿dy kana³ sieci rezydualnej, 
% oraz zwiêkszamy kana³ sieci przep³ywowej o dan¹ wartoœæ (na danej trasie)
MinimumResidualCapacity = min(NewResidualgraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualgraph.Edges.Weight(Edges)= NewResidualgraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl¹da sieæ przep³ywowa z zaznaczon¹ œcie¿k¹ przed zwiêkszeniem odpowiednich wartoœci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfNewCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfNewCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfNewCostGraph(i); % Startowe wêz³y
    EndFlowPathNode(i)=ShortestPathOfNewCostGraph(i+1); % Koñcowe wêz³y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl¹da nasz otrzymany graf sieci przep³ywowej po pierwszym etapie optymalizacji
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
% Aby poni¿szy graf przedstawia³ sieæ rezydualn¹, musimy usun¹æ kana³y
% zbêdne(z zerow¹ przepustowoœci¹) powsta³e w wyniku poprzednich operacji
ResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
L0Widths=find(ResidualLWidths==0);ResidualLWidths(L0Widths)=mean(NewResidualgraph.Edges.Weight)/sum(NewResidualgraph.Edges.Weight);
plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Musimy uwzglêdniæ tak¿e, ¿e przy wyznaczone póŸniej najkrótsze trasy nie mog¹ zawieraæ 
% kana³ów uschniêtych grafu sieci rezydualnej. Dla uproszczenia utworzymy pomocniczy graf
% na podstawie grafu kosztów, jednak bez wspomnianych kana³ów. Nastêpnie za jednym
% razem usuniemy wiêc odpowiednie kana³y w grafie rezydualnym i pomocniczym
SmallerCostGraph = NewCostgraph; % Utworzenie pomocniczego grafu (kosztów)

numbers = find(NewResidualgraph.Edges.Weight==0);
NewResidualgraph=rmedge(NewResidualgraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (Musimy tak¿e usun¹æ wszystkie parametry danej krawêdzi z odpowiednich list)
ResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight); % Szerokoœæ kana³u na rysunku
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku
SmallerCostL0Widths=SmallerCostLWidths==0; %Ustawienie minimalnej gruboœci kana³u na rysunku dla tych z zerowym ksoztem
SmallerCostLWidths(SmallerCostL0Widths)= mean(SmallerCostGraph.Edges.Weight)/sum(SmallerCostGraph.Edges.Weight);

% Tak wygl¹da nasz otrzymany graf sieci rezydualnej po pierwszym etapie
% optymalizacji
GPlotNewResidual = plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Tak wygl¹da nasz otrzymany graf pomocniczy po pierwszym etapie
% optymalizacji
GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,...
    'LineWidth',SmallerCostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
layout(GPlotSmallerCost,'force','WeightEffect','direct') 

% Nastêpnie wracamy do poszukiwania dalszych œcie¿ek rozszerzaj¹cych i analogicznie wykonujemy dalsze czynnoœci, 
% jak w poprzednim etapie algorytmu, jednak tym razem korzystamy z grafu pomocniczego do wyznaczenia œcie¿ek
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'SuperSource','SuperTarget','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth',SmallerCostLWidths); % Rysunek grafu
GPlotSmallerCost.MarkerSize = 7; % Zmiana rozmiaru wêz³ów dla przejrzystoœci rysunku
GPlotSmallerCost.NodeColor='black'; % Zmiana koloru wêz³ów dla przejrzystoœci rysunku
GPlotSmallerCost.EdgeColor='blue'; % Zmiana koloru kana³ów dla przejrzystoœci rysunku
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(NewResidualgraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualgraph.Edges.Weight(Edges)= NewResidualgraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl¹da sieæ przep³ywowa z zaznaczon¹ œcie¿k¹ przed zwiêkszeniem odpowiednich wartoœci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
disp(GPlotFlow);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfSmallerCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i); % Startowe wêz³y
    EndFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i+1); % Koñcowe wêz³y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl¹da nasz otrzymany graf sieci przep³ywowej po drugim etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni¿szy graf przedstawia³ sieæ rezydualn¹, musimy usun¹æ kana³y
% zbêdne(z zerow¹ przepustowoœci¹) powsta³e w wyniku poprzednich operacji
ResidualL0Widths=find(ResidualLWidths==0);
ResidualLWidths(ResidualL0Widths)= mean(NewResidualgraph.Edges.Weight)/sum(NewResidualgraph.Edges.Weight);
GPlotResidual = plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
    ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(NewResidualgraph.Edges.Weight==0);
NewResidualgraph=rmedge(NewResidualgraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (Musimy tak¿e usun¹æ wszystkie parametry danej krawêdzi z odpowiednich list)
ResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight); % Szerokoœæ kana³u na rysunku
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku
SmallerCostL0Widths=find(SmallerCostLWidths==0); %Ustawienie minimalnej gruboœci kana³u na rysunku dla tych z zerowym ksoztem
SmallerCostLWidths(SmallerCostL0Widths)= mean(SmallerCostGraph.Edges.Weight)/sum(SmallerCostGraph.Edges.Weight);

% Tak wygl¹da nasz otrzymany graf sieci rezydualnej po drugim etapie
% optymalizacji
plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
    ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Tak wygl¹da nasz otrzymany graf pomocniczy po pierwszym etapie
% optymalizacji
GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,...
    'LineWidth',SmallerCostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
% layout(GPlotSmallerCost,'force','WeightEffect','direct') 


% Etap trzeci
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'SuperSource','SuperTarget','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);
% Doszliœmy do etapu, w którym nie mo¿emy znaleŸæ œcie¿ki rozszerzaj¹cej.
% Przep³yw nie mo¿e byæ ju¿ bardziej zwiêkszony, a wiêc ostatecznie graf
% sieci przep³ywowej wygl¹da w nastêpuj¹cy sposób (po usuniêciu kana³ów wyschniêtych):
numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',7,'LineWidth',2);
disp('Network has been fully optimised.');
