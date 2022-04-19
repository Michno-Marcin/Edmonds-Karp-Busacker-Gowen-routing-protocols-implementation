%% Przyk�ad pokazuj�cy schemat dzia�ania algorytmu Edmondsa-Karpa (Forda Folkursona z algorytmem BFS do wyznaczenia najkr�tszych �cie�ek opartego na liczbie przeskok�w)
% razem z metod� super�r�de� i superuj��

%% Przygotowanie do wykonania skryptu, wst�pne czyszczenie konsoli, zmiennych, otwartych okien
clear; close all; clc;

%% Przypisanie odpowiednich w�a�ciwo�ci sieci
source  = [1 1 1 2 2 3 3 4 4 5 6 6]; % Pocz�tek kana�u
target_nodes = [2 3 4 3 7 5 7 3 5 7 1 4]; % Koniec kana�u
names = {'A', 'B', 'C',... % Nazwy w�z��w
    'D','E','F','G'};
throughput = [7 3 10 4 6 2 9 3 6 8 9 9]; % Wagi w�z��w
cost = [5 6 3 8 8 2 6 8 9 10 5 6]; % Wagi w�z��w (odleg�o�ci w�z��w)

%% Wizulalizacja sieci rezydualnej 
ResidualGraph = digraph(source,target_nodes,throughput,names); % Utworzenie grafu sieci rezydualnej
ResidualLWidths = 2*ResidualGraph.Edges.Weight/max(ResidualGraph.Edges.Weight); % Szeroko�� kana�u na rysunku
GPlotResidual = plot(ResidualGraph,'EdgeLabel',ResidualGraph.Edges.Weight,'LineWidth',ResidualLWidths); % Rysunek grafu
GPlotResidual.MarkerSize = 7; % Zmiana rozmiaru w�z��w dla przejrzysto�ci rysunku
GPlotResidual.NodeColor='black'; % Zmiana koloru w�z��w dla przejrzysto�ci rysunku
GPlotResidual.EdgeColor='blue'; % Zmiana koloru kana��w dla przejrzysto�ci rysunku
% Mo�emy na wykresie pokaza� wizualnie tak�e stosunek odpowiednich odleg�o�ci mi�dzy w�z�ami
layout(GPlotResidual,'force','WeightEffect','direct') ;


%% Wizualizacja sieci koszt�w
CostGraph = digraph(source,target_nodes,cost,names); % Utworzenie grafu sieci koszt�w
CostLWidths = 2*CostGraph.Edges.Weight/max(CostGraph.Edges.Weight); % Szeroko�� kana�u na rysunku
GPlotCost = plot(CostGraph,'EdgeLabel',CostGraph.Edges.Weight,'LineWidth',CostLWidths); % Rysunek grafu
GPlotCost.MarkerSize = 7; % Zmiana rozmiaru w�z��w dla przejrzysto�ci rysunku
GPlotCost.NodeColor='black'; % Zmiana koloru w�z��w dla przejrzysto�ci rysunku
GPlotCost.EdgeColor='blue'; % Zmiana koloru kana��w dla przejrzysto�ci rysunku
% Mo�emy na wykresie pokaza� wizualnie tak�e stosunek odpowiednich odleg�o�ci mi�dzy w�z�ami
layout(GPlotCost,'force','WeightEffect','direct'); 

%% Przyk�ad algorytmu Forda-Folkursona
% Skorzystamy z utworzonych na pocz�tku graf�w i wizualizacji

% Przed rozpocz�ciem algorytmu szukania �cie�ek musimy wybra� �r�d�a oraz
% uj�cia danej sieci w celu jej optymalizacji. Z grafu wiemy, �e :
% source  = [1 1 2 2 3 3 4 4 5 6 6]; % Pocz�tek kana�u
% target_nodes = [2 3 3 7 5 7 3 5 7 1 4]; % Koniec kana�u
% names = {'A', 'B', 'C', 'D','E','F','G'}; % Nazwy w�z��w

% Wybierzemy na przyk�ad dla �r�de� w�z�y: A, B, C (pierwszy drugi, trzec),a dla uj�� w�z�y: D,E,F.
Sources = [1,2,3]; 
SourcesNames = {char(names(Sources))};disp (SourcesNames{1}); % Funkcja char zamieni typ tablicowy na char
Targets = [4,5,6]; 
TargetsNames = {char(names(Targets))}; disp(TargetsNames{1});

AdWeMatrix = adjacency(ResidualGraph,'weighted');
AdjadencyWeightMatrix = full(AdWeMatrix); disp(AdjadencyWeightMatrix); % Macierz wagowa (s�siedztwa) danego grafu rezydualnego

AdjadencyWeightMatrix(Sources,:) % Wagi kana��w wychodz�cych kolejnych �r�de� (�r�d�a poziomo)
sum(sum(AdjadencyWeightMatrix(Sources,:))) % Suma wag wychodz�cych do wszystkich �r�de� grafu
% Powy�ej wyznaczona zosta�� warto�� przepustowo�ci rezydualnej superuj�r�d�a

AdjadencyWeightMatrix(:,[4,5,6]) % Wagi kana��w wchodz�cych do kolejnych uj��
sum(sum(AdjadencyWeightMatrix(:,[4,5,6]))) % Suma wag wchodz�cych do wszystkich uj�� grafu (uj�cia poziomo)
% Powy�ej wyznaczona zosta�� warto�� przepustowo�ci rezydualnej superuj�cia

% Dodamy super�r�d�o, superuj�cie oraz podpiszemy je
NamesForNewNodes = {'SuperSource', 'SuperTarget'};
ResidualGraph = addnode(ResidualGraph,2);
% ResidualGraph.Nodes
ResidualGraph.Nodes.Name(size(ResidualGraph.Nodes,1)-1:end) = NamesForNewNodes;
% ResidualGraph.Nodes


% Dodamy odpowiednie kana�y i ich przepustowo�ci rezydualne dla super�r�d�a
NewResidualgraph = addedge(ResidualGraph, {'SuperSource'},{'A' 'B','C'}, ...
    sum(AdjadencyWeightMatrix([1,2,3],:),2)); % <-- przepustowo�ci rezydualne kolejnych "��cznik�w"
% NewResidualgraph.Edges
% sum(AdjadencyWeightMatrix([1,2,3],:)');

% Dodamy odpowiednie kana�y i ich przepustowo�ci rezydualne dla superuj�cia
NewResidualgraph = addedge(NewResidualgraph, {'D' 'E','F'},{'SuperTarget'}, ...
    sum(AdjadencyWeightMatrix(:,[4,5,6]))); % <-- przepustowo�ci rezydualne kolejnych "��cznik�w"
% NewResidualgraph.Edges

% Rysunek
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
L0Widths=NewResidualLWidths==0;
NewResidualLWidths(L0Widths)= mean(NewResidualgraph.Edges.Weight)/sum(NewResidualgraph.Edges.Weight);
GPlotNewResidual = plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
% Na zmodyfikowanym grafie mo�emy zacz�� szuka� ju� �cie�ek roszerzaj�cych 
% mi�dzy super�r�d�em, a superuj�ciem korzystaj�c z algorytmu Edmondsa-Karpa.

% W pierwszym kroku zadania zerujemy kana�y sieci przep�ywowej, oraz szukamy najkr�tszej �cie�ki rozszerzaj�cej 
% (sieci rezydualnej) ze super�r�d�a do superuj�cia, bior�c pod uwag� jedynie ilo�� kana��w po drodze
FlowGraph = NewResidualgraph; FlowGraph.Edges.Weight(:)= 0;

[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualgraph,'SuperSource','SuperTarget','Method','unweighted'); 
disp([ShortestPathOfBuiltGraph,Length,Edges]);
% Oznaczymy znalezion� �cie�k� (na sieci rezydualnej)
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
highlight(GPlotNewResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',NewResidualLWidths,'NodeColor','green');

% Szukamy teraz najmniejszej przepustowo�ci rezydualnej na danym strumieniu
% Po jej znalezieniu zmniejszamy ka�dy kana� sieci rezydualnej, 
% oraz zwi�kszamy kana� sieci przep�ywowej o dan� warto�� (na danej trasie)
MinimumResidualCapacity = min(NewResidualgraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualgraph.Edges.Weight(Edges)= NewResidualgraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl�da sie� przep�ywowa z zaznaczon� �cie�k� przed zwi�kszeniem odpowiednich warto�ci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2); disp(GPlotFlow);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

StartFlowPathNode = string.empty; EndFlowPathNode = string.empty;
for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i); % Startowe w�z�y
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % Ko�cowe w�z�y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl�da nasz otrzymany graf sieci przep�ywowej po pierwszym etapie optymalizacji
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
% Aby poni�szy graf przedstawia� sie� rezydualn�, musimy usun�� kana�y
% zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
NewL0Widths=NewResidualLWidths==0;
NewResidualLWidths(NewL0Widths)=mean(NewResidualgraph.Edges.Weight)/sum(NewResidualgraph.Edges.Weight);
plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(NewResidualgraph.Edges.Weight==0);
NewResidualgraph=rmedge(NewResidualgraph,numbers);
% (Musimy tak�e usun�� wszystkie parametry danej kraw�dzi z odpowiednich list)
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight); % Szeroko�� kana�u na rysunku

% Tak wygl�da nasz otrzymany graf sieci rezydualnej po pierwszym etapie
% optymalizacji
GPlotNewResidual = plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,...
    'LineWidth',NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
% layout(GPlotResidual,'force','WeightEffect','direct') 


% Nast�pnie wracamy do poszukiwania dalszych �cie�ek rozszerzaj�cych i
% analogicznie wykonujemy dalsze czynno�ci
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualgraph,'SuperSource','SuperTarget','Method','unweighted'); 
disp([ShortestPathOfBuiltGraph,Length,Edges]);
highlight(GPlotNewResidual,ShortestPathOfBuiltGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');
MinimumResidualCapacity = min(NewResidualgraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualgraph.Edges.Weight(Edges)= NewResidualgraph.Edges.Weight(Edges) - MinimumResidualCapacity;
% Dla sieci przep�ywowej identyfikatory odpowiednich kana��w nie b�d� identyczne z powodu zmiany kierunku �cie�ki. 
% Utworzymy wi�c na niej wielokrotne kraw�dzie, a nast�pnie upro�cimy je tworz�c ich sum�.

% Tak wygl�da sie� przep�ywowa z zaznaczon� �ci�zk� przed zwi�kszeniem odpowiednich warto�ci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
disp(GPlotFlow);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfBuiltGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfBuiltGraph(i); % Startowe w�z�y
    EndFlowPathNode(i)=ShortestPathOfBuiltGraph(i+1); % Ko�cowe w�z�y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl�da nasz otrzymany graf sieci przep�ywowej po drugim etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfBuiltGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni�szy graf przedstawia� sie� rezydualn�, musimy usun�� kana�y
% zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
NewL0Widths=NewResidualLWidths==0;
NewResidualLWidths(NewL0Widths)= mean(NewResidualgraph.Edges.Weight)/sum(NewResidualgraph.Edges.Weight);
plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(NewResidualgraph.Edges.Weight==0);
NewResidualgraph=rmedge(NewResidualgraph,numbers);
% (Musimy tak�e usun�� wszystkie parametry danej kraw�dzi z odpowiednich list)
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight); % Szeroko�� kana�u na rysunku

% Tak wygl�da nasz otrzymany graf sieci rezydualnej po drugim etapie
% optymalizacji
GPlotNewResidual = plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
layout(GPlotNewResidual,'force','WeightEffect','direct') 


% Etap trzeci
[ShortestPathOfBuiltGraph,Length,Edges] = shortestpath(NewResidualgraph,'SuperSource','SuperTarget','Method','unweighted');
disp([ShortestPathOfBuiltGraph,Length,Edges]);
% Doszli�my do etapu, w kt�rym nie mo�emy znale�� �cie�ki rozszerzaj�cej dla superuj�cia i super�r�d�a.
% Przep�yw nie mo�e by� ju� bardziej zwi�kszony. usuniemy wi�c teraz
% sztuczne "Super�r�d�o" oraz sztuczne "SuperUj�cie z grafu".
NewResidualgraph=rmnode(NewResidualgraph,[{'SuperSource'},{'SuperTarget'}]);

% Graf rezydualny danej sieci wygl�da wi�c nast�puj�co:
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
NewL0Widths=find(NewResidualLWidths==0);
NewResidualLWidths(NewL0Widths)= mean(NewResidualgraph.Edges.Weight)/sum(NewResidualgraph.Edges.Weight);
plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
    NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7)

% Ostatecznie graf sieci przep�ywowej wygl�da w nast�puj�cy spos�b (po usuni�ciu kana��w wyschni�tych):
numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',7,'LineWidth',2); disp(GPlotFlow);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Przyk�ad algorytmu Busackera-Gowena dla sieci z okre�lonymi kosztami, z zastosowaniem superuj��, super�r�de�
% Skorzystamy z utworzonych na pocz�tku graf�w i wizualizacji
% Wybierzemy na przyk�ad dla �r�de� w�z�y: A, B, C (pierwszy drugi, trzeci),a dla uj�� w�z�y: D,E,F.
SourcesNames={char(names(1)), char(names(2)), char(names(3))}; % Funkcja char zamieni typ tablicowy na char
TargetsNames = {char(names(4)), char(names(5)), char(names(6))};

AdWeMatrix = adjacency(ResidualGraph,'weighted');
AdjadencyWeightMatrix = full(AdWeMatrix); disp(AdjadencyWeightMatrix); disp(AdjadencyWeightMatrix); 
% Macierz wagowa (s�siedztwa) danego grafu rezydualnego

disp(AdjadencyWeightMatrix([1,2,3],:)'); % Wagi kana��w wychodz�cych kolejnych �r�de� (�r�d�a poziomo)
sum(sum(AdjadencyWeightMatrix([1,2,3],:))) % Suma wag wychodz�cych do wszystkich �r�de� grafu
% Powy�ej wyznaczona zosta�� warto�� przepustowo�ci rezydualnej superuj�r�d�a

AdjadencyWeightMatrix(:,[4,5,6]) % Wagi kana��w wchodz�cych do kolejnych uj��
sum(sum(AdjadencyWeightMatrix(:,[4,5,6]))) % Suma wag wchodz�cych do wszystkich uj�� grafu (uj�cia poziomo)
% Powy�ej wyznaczona zosta�� warto�� przepustowo�ci rezydualnej superuj�cia

% Dodamy super�r�d�o, superuj�cie oraz podpiszemy je. 
% Przyjmiemy umownie, �e koszt kana��w wychodz�cych/wchodz�cych z nimi powi�zanymi wynosi 0.
NamesForNewNodes = {'SuperSource', 'SuperTarget'};
ResidualGraph = addnode(ResidualGraph,2);
CostGraph = addnode(CostGraph,2);
% ResidualGraph.Nodes
% CostGraph.Nodes
ResidualGraph.Nodes.Name(size(ResidualGraph.Nodes,1)-1:end) = NamesForNewNodes;
CostGraph.Nodes.Name(size(CostGraph.Nodes,1)-1:end) = NamesForNewNodes;
% ResidualGraph.Nodes.Name
% CostGraph.Nodes.Name

% Dodamy odpowiednie kana�y i ich przepustowo�ci rezydualne dla super�r�d�a w grafie sieci rezydualnej i koszt�w
NewResidualgraph = addedge(ResidualGraph, {'SuperSource'},{'A' 'B','C'}, ...
    sum(AdjadencyWeightMatrix([1,2,3],:),2)); % <-- przepustowo�ci rezydualne kolejnych "��cznik�w"
NewCostgraph = addedge(CostGraph, {'SuperSource'},{'A' 'B','C'},[0 0 0]); % <-- koszty "��cznik�w"
% NewResidualgraph.Edges
% sum(AdjadencyWeightMatrix([1,2,3],:)')
% NewCostgraph.Edges

% Dodamy odpowiednie kana�y i ich przepustowo�ci rezydualne dla superuj�cia w grafie sieci rezydualnej i koszt�w
NewResidualgraph = addedge(NewResidualgraph, {'D' 'E','F'},{'SuperTarget'}, ...
    sum(AdjadencyWeightMatrix([1,2,3],:),2)); % <-- przepustowo�ci rezydualne kolejnych "��cznik�w"
NewCostgraph = addedge(NewCostgraph, {'D' 'E','F'},{'SuperTarget'}, [0 0 0]); % <-- koszty "��cznik�w"
% NewResidualgraph.Edges
% NewCostgraph.Edges

% Wizualizacja zmodyfikowanych graf�w sieci koszt�w i grafu sieci rezydualnej
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

% Na zmodyfikowanych grafach mo�emy zacz�� szuka� ju� �cie�ek roszerzaj�cych 
% mi�dzy super�r�d�em, a superuj�ciem korzystaj�c z algorytmu Busackera-Gowena

% W pierwszym kroku algorytmu zerujemy kana�y sieci przep�ywowej, oraz szukamy najkr�tszej �cie�ki rozszerzaj�cej 
% (w grafie z wagami okre�laj�cymi odpowiednie koszty) ze �r�d�a s do uj�cia t, bior�c pod uwag� koszty/odleg�o�ci 
FlowGraph = NewResidualgraph; FlowGraph.Edges.Weight(:)= 0;


% Wyznaczenie najkr�tszej �cie�ki metod� Djikstry od super�r�d�a do superuj�� na podstawie macierzy koszt�w
[ShortestPathOfNewCostGraph,Length,Edges] = shortestpath(NewCostgraph,'SuperSource','SuperTarget','Method','positive');
disp([ShortestPathOfNewCostGraph,Length,Edges]);
% Poka�emy wyznaczon� odpowiadaj�c� najkr�tszej �cie�ce z sieci koszt�w �cie�k� w sieci rezydualnej)
GPlotNewResidual = plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',ResidualLWidths); % Rysunek grafu
GPlotNewResidual.MarkerSize = 7; % Zmiana rozmiaru w�z��w dla przejrzysto�ci rysunku
GPlotNewResidual.NodeColor='black'; % Zmiana koloru w�z��w dla przejrzysto�ci rysunku
GPlotNewResidual.EdgeColor='blue'; % Zmiana koloru kana��w dla przejrzysto�ci rysunku
highlight(GPlotNewResidual,ShortestPathOfNewCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

% Szukamy teraz najmniejszej przepustowo�ci rezydualnej na danym strumieniu
% Po jej znalezieniu zmniejszamy ka�dy kana� sieci rezydualnej, 
% oraz zwi�kszamy kana� sieci przep�ywowej o dan� warto�� (na danej trasie)
MinimumResidualCapacity = min(NewResidualgraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualgraph.Edges.Weight(Edges)= NewResidualgraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl�da sie� przep�ywowa z zaznaczon� �cie�k� przed zwi�kszeniem odpowiednich warto�ci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfNewCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfNewCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfNewCostGraph(i); % Startowe w�z�y
    EndFlowPathNode(i)=ShortestPathOfNewCostGraph(i+1); % Ko�cowe w�z�y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl�da nasz otrzymany graf sieci przep�ywowej po pierwszym etapie optymalizacji
plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,...
    'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
% Aby poni�szy graf przedstawia� sie� rezydualn�, musimy usun�� kana�y
% zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
ResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
L0Widths=find(ResidualLWidths==0);ResidualLWidths(L0Widths)=mean(NewResidualgraph.Edges.Weight)/sum(NewResidualgraph.Edges.Weight);
plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Musimy uwzgl�dni� tak�e, �e przy wyznaczone p�niej najkr�tsze trasy nie mog� zawiera� 
% kana��w uschni�tych grafu sieci rezydualnej. Dla uproszczenia utworzymy pomocniczy graf
% na podstawie grafu koszt�w, jednak bez wspomnianych kana��w. Nast�pnie za jednym
% razem usuniemy wi�c odpowiednie kana�y w grafie rezydualnym i pomocniczym
SmallerCostGraph = NewCostgraph; % Utworzenie pomocniczego grafu (koszt�w)

numbers = find(NewResidualgraph.Edges.Weight==0);
NewResidualgraph=rmedge(NewResidualgraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (Musimy tak�e usun�� wszystkie parametry danej kraw�dzi z odpowiednich list)
ResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight); % Szeroko�� kana�u na rysunku
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight); % Szeroko�� kana�u na rysunku
SmallerCostL0Widths=SmallerCostLWidths==0; %Ustawienie minimalnej grubo�ci kana�u na rysunku dla tych z zerowym ksoztem
SmallerCostLWidths(SmallerCostL0Widths)= mean(SmallerCostGraph.Edges.Weight)/sum(SmallerCostGraph.Edges.Weight);

% Tak wygl�da nasz otrzymany graf sieci rezydualnej po pierwszym etapie
% optymalizacji
GPlotNewResidual = plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,...
    'LineWidth',ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Tak wygl�da nasz otrzymany graf pomocniczy po pierwszym etapie
% optymalizacji
GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,...
    'LineWidth',SmallerCostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
layout(GPlotSmallerCost,'force','WeightEffect','direct') 

% Nast�pnie wracamy do poszukiwania dalszych �cie�ek rozszerzaj�cych i analogicznie wykonujemy dalsze czynno�ci, 
% jak w poprzednim etapie algorytmu, jednak tym razem korzystamy z grafu pomocniczego do wyznaczenia �cie�ek
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'SuperSource','SuperTarget','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);

GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,'LineWidth',SmallerCostLWidths); % Rysunek grafu
GPlotSmallerCost.MarkerSize = 7; % Zmiana rozmiaru w�z��w dla przejrzysto�ci rysunku
GPlotSmallerCost.NodeColor='black'; % Zmiana koloru w�z��w dla przejrzysto�ci rysunku
GPlotSmallerCost.EdgeColor='blue'; % Zmiana koloru kana��w dla przejrzysto�ci rysunku
highlight(GPlotSmallerCost,ShortestPathOfSmallerCostGraph,'EdgeColor','r','LineWidth',2,'NodeColor','green');

MinimumResidualCapacity = min(NewResidualgraph.Edges.Weight(Edges)); disp(MinimumResidualCapacity);
NewResidualgraph.Edges.Weight(Edges)= NewResidualgraph.Edges.Weight(Edges) - MinimumResidualCapacity;

% Tak wygl�da sie� przep�ywowa z zaznaczon� �cie�k� przed zwi�kszeniem odpowiednich warto�ci
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
disp(GPlotFlow);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

for i=1:(length(ShortestPathOfSmallerCostGraph)-1)
    StartFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i); % Startowe w�z�y
    EndFlowPathNode(i)=ShortestPathOfSmallerCostGraph(i+1); % Ko�cowe w�z�y
    FlowGraph = addedge(FlowGraph, StartFlowPathNode(i),EndFlowPathNode(i), MinimumResidualCapacity);
    FlowGraph=simplify(FlowGraph,'sum');
end
% Tak wygl�da nasz otrzymany graf sieci przep�ywowej po drugim etapie
% optymalizacji
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor',...
    'red','EdgeColor','green','MarkerSize',7,'LineWidth',2);
highlight(GPlotFlow,ShortestPathOfSmallerCostGraph,'EdgeColor','b','LineWidth',2,'NodeColor','black');

% A aby poni�szy graf przedstawia� sie� rezydualn�, musimy usun�� kana�y
% zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
ResidualL0Widths=find(ResidualLWidths==0);
ResidualLWidths(ResidualL0Widths)= mean(NewResidualgraph.Edges.Weight)/sum(NewResidualgraph.Edges.Weight);
GPlotResidual = plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
    ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

numbers = find(NewResidualgraph.Edges.Weight==0);
NewResidualgraph=rmedge(NewResidualgraph,numbers);
SmallerCostGraph=rmedge(SmallerCostGraph,numbers);
% (Musimy tak�e usun�� wszystkie parametry danej kraw�dzi z odpowiednich list)
ResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight); % Szeroko�� kana�u na rysunku
SmallerCostLWidths = 2*SmallerCostGraph.Edges.Weight/max(SmallerCostGraph.Edges.Weight); % Szeroko�� kana�u na rysunku
SmallerCostL0Widths=find(SmallerCostLWidths==0); %Ustawienie minimalnej grubo�ci kana�u na rysunku dla tych z zerowym ksoztem
SmallerCostLWidths(SmallerCostL0Widths)= mean(SmallerCostGraph.Edges.Weight)/sum(SmallerCostGraph.Edges.Weight);

% Tak wygl�da nasz otrzymany graf sieci rezydualnej po drugim etapie
% optymalizacji
plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
    ResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);

% Tak wygl�da nasz otrzymany graf pomocniczy po pierwszym etapie
% optymalizacji
GPlotSmallerCost = plot(SmallerCostGraph,'EdgeLabel',SmallerCostGraph.Edges.Weight,...
    'LineWidth',SmallerCostLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
% layout(GPlotSmallerCost,'force','WeightEffect','direct') 


% Etap trzeci
[ShortestPathOfSmallerCostGraph,Length,Edges] = shortestpath(SmallerCostGraph,'SuperSource','SuperTarget','Method','positive');
disp([ShortestPathOfSmallerCostGraph,Length,Edges]);
% Doszli�my do etapu, w kt�rym nie mo�emy znale�� �cie�ki rozszerzaj�cej.
% Przep�yw nie mo�e by� ju� bardziej zwi�kszony, a wi�c ostatecznie graf
% sieci przep�ywowej wygl�da w nast�puj�cy spos�b (po usuni�ciu kana��w wyschni�tych):
numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
GPlotFlow = plot(FlowGraph,'EdgeLabel',FlowGraph.Edges.Weight,'NodeColor','red',...
    'EdgeColor','green','MarkerSize',7,'LineWidth',2);
disp('Network has been fully optimised.');
