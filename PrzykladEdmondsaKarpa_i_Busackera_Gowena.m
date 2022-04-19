% Przyk³ad pokazuj¹cy schemat dzia³ania algorytmu Edmondsa-Karpa (Forda
% Folkursona z algorytmem BFS do wyznaczenia najkrótszych œcie¿ek opartego na liczbie przeskoków)

% Przyk³ad pokazuj¹cy schemat dzia³ania algorytmu Busackera-Gowena dla sieci z okreœlonymi kosztami
%% Przygotowanie do wykonania skryptu, wstêpne czyszczenie konsoli, zmiennych, otwartych okien
clear; close all; clc;
%% Przypisanie odpowiednich w³aœciwoœci sieci
source  = [1 1 2 2 3 3 4 4 5 6 6]; % Pocz¹tek kana³u
target_nodes = [2 3 3 7 5 7 3 5 7 1 4]; % Koniec kana³u
names = {'A', 'B', 'C',... % Nazwy wêz³ów
    'D','E','s','t'};
throughput = [7 3 4 6 2 9 3 6 8 9 9]; % Wagi wêz³ów (przepustowoœæ rezydualna) % ew bandwidth nazwa jak dla sieci
cost = [5 6 3 8 8 2 6 8 9 10 5]; % Wagi wêz³ów (odleg³oœci wêz³ów)

%% Wizulalizacja sieci rezydualnej 

ResidualGraph = digraph(source,target_nodes,throughput,names); % Utworzenie grafu sieci rezydualnej
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku
GPlotResidual = plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,'LineWidth',ResidualLWidths); % Rysunek grafu
GPlotResidual.MarkerSize = 7; % Zmiana rozmiaru wêz³ów dla przejrzystoœci rysunku
GPlotResidual.NodeColor='black'; % Zmiana koloru wêz³ów dla przejrzystoœci rysunku
GPlotResidual.EdgeColor='blue'; % Zmiana koloru kana³ów dla przejrzystoœci rysunku

%% Wizualizacja sieci kosztów
CostGraph = digraph(source,target_nodes,cost,names); % Utworzenie grafu sieci kosztów
CostLWidths = 2*CostGraph.Edges.Weight/max(CostGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku
GPlotCost = plot(CostGraph,'EdgeLabel',CostGraph.Edges.Weight,'LineWidth',CostLWidths); % Rysunek grafu
GPlotCost.MarkerSize = 7; % Zmiana rozmiaru wêz³ów dla przejrzystoœci rysunku
GPlotCost.NodeColor='black'; % Zmiana koloru wêz³ów dla przejrzystoœci rysunku
GPlotCost.EdgeColor='blue'; % Zmiana koloru kana³ów dla przejrzystoœci rysunku
% Mo¿emy na wykresie pokazaæ wizualnie tak¿e stosunek odpowiednich odleg³oœci miêdzy wêz³ami
layout(GPlotCost,'force','WeightEffect','direct') ;

%% Przyk³adowe macierze danych dla sieci rezydualnej
% AdjandencyMatrix = full(adjacency(ResidualGraph)) % Macierz s¹siedztwa danego grafu
% AdWeMatrix = adjacency(ResidualGraph,'weighted');
% AdjadencyWeightMatrix = full(AdWeMatrix) % Macierz wagowa (s¹siedztwa) danego grafu
% IMatrix = incidence(ResidualGraph);
% IncidenceMatrix = full(IMatrix) % Macierz incydencji danego grafu

%% Przyk³ad algorytmu Forda-Folkursona

% Skorzystamy z utworzonych na pocz¹tku grafów i wizualizacji
% W pierwszym kroku algorytmu zerujemy kana³y sieci przep³ywowej, oraz szukamy najkrótszej œcie¿ki rozszerzaj¹cej 
% (sieci rezydualnej) ze Ÿród³a s do ujœcia t, bior¹c pod uwagê jedynie iloœæ kana³ów po drodze
FlowGraph = ResidualGraph; FlowGraph.Edges.Weight(:)= 0; NewResidualGraph=ResidualGraph; 
NewResidualLWidths=ResidualLWidths;

% Wyznaczenie najkrótszej œcie¿ki metod¹ BFS ("niewagow¹")
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted'); 
disp([ShortestPathOfBuiltGraph,Length,Edges]);
% Oznaczymy znalezion¹ œcie¿kê (na sieci rezydualnej)
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',NewResidualLWidths); % Rysunek grafu
GPlotResidual.MarkerSize = 7; % Zmiana rozmiaru wêz³ów dla przejrzystoœci rysunku
GPlotResidual.NodeColor='black'; % Zmiana koloru wêz³ów dla przejrzystoœci rysunku
GPlotResidual.EdgeColor='blue'; % Zmiana koloru kana³ów dla przejrzystoœci rysunku
highlight(GPlotResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

% Szukamy teraz najmniejszej przepustowoœci rezydualnej na danej trasie
% Po jej znalezieniu zmniejszamy ka¿dy kana³ sieci rezydualnej, 
% oraz zwiêkszamy kana³ sieci przep³ywowej o dan¹ wartoœæ (na danej trasie)
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl¹da sieæ przep³ywowa z zaznaczon¹ œcie¿k¹ przed zwiêkszeniem odpowiednich wartoœci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
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
LWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
L0Widths=find(LWidths==0);LWidths(L0Widths)=mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku

% Tak wygl¹da nasz otrzymany graf sieci rezydualnej po pierwszym etapie
% optymalizacji
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Nastêpnie wracamy do poszukiwania dalszych œcie¿ek rozszerzaj¹cych i
% analogicznie wykonujemy dalsze czynnoœci
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted'); 
disp([ShortestPathOfBuiltGraph,Length,Edges]);
highlight(GPlotResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl¹da sieæ przep³ywowa z zaznaczon¹ œciê¿k¹ przed zwiêkszeniem odpowiednich wartoœci
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
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
ResidualL0Widths=NewResidualLWidths==0;
NewResidualLWidths(ResidualL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku

% Tak wygl¹da nasz otrzymany graf sieci rezydualnej po drugim etapie
% optymalizacji
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Analogicznie w etapie trzecim:
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
highlight(GPlotResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl¹da sieæ przep³ywowa z zaznaczon¹ œcie¿k¹ przed zwiêkszeniem odpowiednich wartoœci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i); % Startowe wêz³y
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % Koñcowe wêz³y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl¹da nasz otrzymany graf sieci przep³ywowej po trzecim etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni¿szy graf przedstawia³ sieæ rezydualn¹, musimy usun¹æ kana³y
% zbêdne(z zerow¹ przepustowoœci¹) powsta³e w wyniku poprzednich operacji
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
ResidualL0Widths=NewResidualLWidths==0;
NewResidualLWidths(ResidualL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight);
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku

% Tak wygl¹da nasz otrzymany graf sieci rezydualnej po trzecim etapie
% optymalizacji
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Etap czwarty ...
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
highlight(GPlotResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl¹da sieæ przep³ywowa z zaznaczon¹ œciêzk¹ przed zwiêkszeniem odpowiednich wartoœci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i); % Startowe wêz³y
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % Koñcowe wêz³y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl¹da nasz otrzymany graf sieci przep³ywowej po czwartym etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni¿szy graf przedstawia³ sieæ rezydualn¹, musimy usun¹æ kana³y
% zbêdne(z zerow¹ przepustowoœci¹) powsta³e w wyniku poprzednich operacji
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
ResidualL0Widths=NewResidualLWidths==0; NewResidualLWidths(ResidualL0Widths)= mean(NewResidualGraph.Edges.Weight)/sum(NewResidualGraph.Edges.Weight); 
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(NewResidualGraph.Edges.Weight==0);
NewResidualGraph=rmedge(NewResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku

% Tak wygl¹da nasz otrzymany graf sieci rezydualnej po czwartym etapie
% optymalizacji
plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Etap pi¹ty
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualGraph,'s','t','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
% Doszliœmy do etapu, w którym nie mo¿emy znaleŸæ œcie¿ki rozszerzaj¹cej.
% Przep³yw nie mo¿e byæ ju¿ bardziej zwiêkszony, a wiêc ostatecznie: graf
% sieci przep³ywowej wygl¹da w nastêpuj¹cy sposób (po usuniêciu kana³ów wyschniêtych):
numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',7,'LineWidth',2);
disp('Network has been fully optimised.');


%% Przyk³ad algorytmu Busackera-Gowena dla sieci z okreœlonymi kosztami
% Skorzystamy z utworzonych na pocz¹tku grafów i wizualizacji
% W pierwszym kroku algorytmu zerujemy kana³y sieci przep³ywowej, oraz szukamy najkrótszej œcie¿ki rozszerzaj¹cej 
% (w grafie z wagami okreœlaj¹cymi odpowiednie koszty) ze Ÿród³a s do ujœcia t, bior¹c pod uwagê koszty/odleg³oœci 
FlowGraph = ResidualGraph; FlowGraph.Edges.Weight(:)= 0; NewResidualGraph=ResidualGraph; 
NewResidualLWidths=ResidualLWidths;

% Wyznaczenie najkrótszej œcie¿ki metod¹ Djikstry (dla ³uków okreœlonych dodatnio)
[ShortestPathOfCostGraph,Length,Edges] = shortestpath(CostGraph,'s','t','Method','positive');
disp([ShortestPathOfCostGraph,Length,Edges]);
GPlotCost = plot(CostGraph,'EdgeLabel',CostGraph.Edges.Weight,'LineWidth',CostLWidths); % Rysunek grafu
GPlotCost.MarkerSize = 7; % Zmiana rozmiaru wêz³ów dla przejrzystoœci rysunku
GPlotCost.NodeColor='black'; % Zmiana koloru wêz³ów dla przejrzystoœci rysunku
GPlotCost.EdgeColor='blue'; % Zmiana koloru kana³ów dla przejrzystoœci rysunku
layout(GPlotCost,'force','WeightEffect','direct') ;
highlight(GPlotCost,ShortestPathOfCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

% Poka¿emy wyznaczon¹ odpowiadaj¹c¹ najkrótszej œcie¿ce z sieci kosztów œcie¿kê w sieci rezydualnej)
GPlotResidual = plot(NewResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,'LineWidth',ResidualLWidths); % Rysunek grafu
GPlotResidual.MarkerSize = 7; % Zmiana rozmiaru wêz³ów dla przejrzystoœci rysunku
GPlotResidual.NodeColor='black'; % Zmiana koloru wêz³ów dla przejrzystoœci rysunku
GPlotResidual.EdgeColor='blue'; % Zmiana koloru kana³ów dla przejrzystoœci rysunku
highlight(GPlotResidual,ShortestPathOfCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

% Szukamy teraz najmniejszej przepustowoœci rezydualnej na danej trasie
% Po jej znalezieniu zmniejszamy ka¿dy kana³ sieci rezydualnej, 
% oraz zwiêkszamy kana³ sieci przep³ywowej o dan¹ wartoœæ (na danej trasie)
MinimumResidualCapacity = min(NewResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualGraph.Edges.Weight(Edges)= NewResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl¹da sieæ przep³ywowa z zaznaczon¹ œcie¿k¹ przed zwiêkszeniem odpowiednich wartoœci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfCostGraph(i); % Startowe wêz³y
    EndFlowPathNode(i)=ShortestPathOfCostGraph(i+1); % Koñcowe wêz³y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl¹da nasz otrzymany graf sieci przep³ywowej po pierwszym etapie optymalizacji
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
% Aby poni¿szy graf przedstawia³ sieæ rezydualn¹, musimy usun¹æ kana³y
% zbêdne(z zerow¹ przepustowoœci¹) powsta³e w wyniku poprzednich operacji
ResidualLWidths = 2*NewResidualGraph.Edges.Weight/max(NewResidualGraph.Edges.Weight);
ResidualL0Widths=ResidualLWidths==0;
ResidualLWidths(ResidualL0Widths) = mean(ResidualGraph.Edges.Weight)/sum(ResidualGraph.Edges.Weight);
plot(ResidualGraph,'EdgeLabel',NewResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Musimy uwzglêdniæ tak¿e, ¿e przy wyznaczone póŸniej najkrótsze trasy nie mog¹ zawieraæ 
% kana³ów uschniêtych grafu sieci rezydualnej. Dla uproszczenia utworzymy pomocniczy graf
% na podstawie grafu kosztów, jednak bez wspomnianych kana³ów. Nastêpnie za jednym
% razem usuniemy wiêc odpowiednie kana³y w grafie rezydualnym i pomocniczym
SmallerCostGraph = digraph(source,target_nodes,cost,names); % Utworzenie pomocniczego grafu (kosztów)

numbers = find(ResidualGraph.Edges.Weight==0);
ResidualGraph=rmedge(ResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (Musimy tak¿e usun¹æ wszystkie parametry danej krawêdzi z odpowiednich list)
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku

% Tak wygl¹da nasz otrzymany graf sieci rezydualnej po pierwszym etapie
% optymalizacji
plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
% Tak wygl¹da nasz otrzymany graf pomocniczy po pierwszym etapie
% optymalizacji
plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,...
    'LineWidth',SmallerCostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Nastêpnie wracamy do poszukiwania dalszych œcie¿ek rozszerzaj¹cych i
% analogicznie wykonujemy dalsze czynnoœci, jak w poprzednim etapie
% algorytmu, jednak tym razem korzystamy z grafu pomocniczego do wyznaczenia œcie¿ek
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth',SmallerCostLWidths); % Rysunek grafu
GPlotSmallerCost.MarkerSize = 7; % Zmiana rozmiaru wêz³ów dla przejrzystoœci rysunku
GPlotSmallerCost.NodeColor='black'; % Zmiana koloru wêz³ów dla przejrzystoœci rysunku
GPlotSmallerCost.EdgeColor='blue'; % Zmiana koloru kana³ów dla przejrzystoœci rysunku
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(ResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
ResidualGraph.Edges.Weight(Edges)= ResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl¹da sieæ przep³ywowa z zaznaczon¹ œcie¿k¹ przed zwiêkszeniem odpowiednich wartoœci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
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
ResidualL0Widths = ResidualLWidths==0; 
ResidualLWidths(ResidualL0Widths)= mean(ResidualGraph.Edges.Weight)/sum(ResidualGraph.Edges.Weight);
plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,'LineWidth',...
    ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(ResidualGraph.Edges.Weight==0);
ResidualGraph=rmedge(ResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (Musimy tak¿e usun¹æ wszystkie parametry danej krawêdzi z odpowiednich list)
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku

% Tak wygl¹da nasz otrzymany graf sieci rezydualnej po drugim etapie optymalizacji
plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
% Tak wygl¹da nasz otrzymany graf pomocniczy po drugim etapie optymalizacji
plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,...
    'LineWidth',SmallerCostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Analogicznie w etapie trzecim:
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth',SmallerCostLWidths); % Rysunek grafu
GPlotSmallerCost.MarkerSize = 7; % Zmiana rozmiaru wêz³ów dla przejrzystoœci rysunku
GPlotSmallerCost.NodeColor='black'; % Zmiana koloru wêz³ów dla przejrzystoœci rysunku
GPlotSmallerCost.EdgeColor='blue'; % Zmiana koloru kana³ów dla przejrzystoœci rysunku
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(ResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
ResidualGraph.Edges.Weight(Edges)= ResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl¹da sieæ przep³ywowa z zaznaczon¹ œciê¿k¹ przed zwiêkszeniem odpowiednich wartoœci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfSmallerCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i); % Startowe wêz³y
    EndFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i+1); % Koñcowe wêz³y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl¹da nasz otrzymany graf sieci przep³ywowej po trzecim etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni¿szy graf przedstawia³ sieæ rezydualn¹, musimy usun¹æ kana³y
% zbêdne(z zerow¹ przepustowoœci¹) powsta³e w wyniku poprzednich operacji
ResidualL0Widths=ResidualLWidths==0;
ResidualLWidths(ResidualL0Widths)= mean(ResidualGraph.Edges.Weight)/sum(ResidualGraph.Edges.Weight);
plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(ResidualGraph.Edges.Weight==0);
ResidualGraph=rmedge(ResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (Musimy tak¿e usun¹æ wszystkie parametry danej krawêdzi z odpowiednich list)
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku

% Tak wygl¹da nasz otrzymany graf sieci rezydualnej po trzecim etapie
% optymalizacji
GPlotResidual = plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
disp(GPlotResidual);
% layout(GPlotResidual,'force','WeightEffect','direct') 

% Etap czwarty ...
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth',SmallerCostLWidths); % Rysunek grafu
GPlotSmallerCost.MarkerSize = 7; % Zmiana rozmiaru wêz³ów dla przejrzystoœci rysunku
GPlotSmallerCost.NodeColor='black'; % Zmiana koloru wêz³ów dla przejrzystoœci rysunku
GPlotSmallerCost.EdgeColor='blue'; % Zmiana koloru kana³ów dla przejrzystoœci rysunku
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(ResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
ResidualGraph.Edges.Weight(Edges)= ResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl¹da sieæ przep³ywowa z zaznaczon¹ œciêzk¹ przed zwiêkszeniem odpowiednich wartoœci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfSmallerCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i); % Startowe wêz³y
    EndFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i+1); % Koñcowe wêz³y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl¹da nasz otrzymany graf sieci przep³ywowej po czwartym etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni¿szy graf przedstawia³ sieæ rezydualn¹, musimy usun¹æ kana³y
% zbêdne(z zerow¹ przepustowoœci¹) powsta³e w wyniku poprzednich operacji
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight);
ResidualL0Widths=ResidualLWidths==0;ResidualLWidths(ResidualL0Widths)= mean(ResidualGraph.Edges.Weight)/sum(ResidualGraph.Edges.Weight);
plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(ResidualGraph.Edges.Weight==0);
ResidualGraph=rmedge(ResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (Musimy tak¿e usun¹æ wszystkie parametry danej krawêdzi z odpowiednich list)
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku

% Tak wygl¹da nasz otrzymany graf sieci rezydualnej po czwartym etapie
% optymalizacji
plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Etap pi¹ty ...
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth',SmallerCostLWidths); % Rysunek grafu
GPlotSmallerCost.MarkerSize = 7; % Zmiana rozmiaru wêz³ów dla przejrzystoœci rysunku
GPlotSmallerCost.NodeColor='black'; % Zmiana koloru wêz³ów dla przejrzystoœci rysunku
GPlotSmallerCost.EdgeColor='blue'; % Zmiana koloru kana³ów dla przejrzystoœci rysunku
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(ResidualGraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
ResidualGraph.Edges.Weight(Edges)= ResidualGraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl¹da sieæ przep³ywowa z zaznaczon¹ œciêzk¹ przed zwiêkszeniem odpowiednich wartoœci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfSmallerCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i); % Startowe wêz³y
    EndFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i+1); % Koñcowe wêz³y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl¹da nasz otrzymany graf sieci przep³ywowej po pi¹tym etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni¿szy graf przedstawia³ sieæ rezydualn¹, musimy usun¹æ kana³y
% zbêdne(z zerow¹ przepustowoœci¹) powsta³e w wyniku poprzednich operacji
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight);
ResidualL0Widths=find(ResidualLWidths==0);ResidualLWidths(ResidualL0Widths)= mean(ResidualGraph.Edges.Weight)/sum(ResidualGraph.Edges.Weight);
plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(ResidualGraph.Edges.Weight==0);
ResidualGraph=rmedge(ResidualGraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (Musimy tak¿e usun¹æ wszystkie parametry danej krawêdzi z odpowiednich list)
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight); % Szerokoœæ kana³u na rysunku

% Tak wygl¹da nasz otrzymany graf sieci rezydualnej po pi¹tym etapie
% optymalizacji
GPlotResidual = plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Etap szósty
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'s','t','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);
% Doszliœmy do etapu, w którym nie mo¿emy znaleŸæ œcie¿ki rozszerzaj¹cej.
% Przep³yw nie mo¿e byæ ju¿ bardziej zwiêkszony, a wiêc ostatecznie graf
% sieci przep³ywowej wygl¹da w nastêpuj¹cy sposób (po usuniêciu kana³ów wyschniêtych):
numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',7,'LineWidth',2);
disp('Network has been fully optimised.');
