%% Przyk�adowe zad. pokazuj�ce schemat dzia�ania algorytmu Edmondsa-Karpa 
% W tym zastosowanie metody super�r�de�, superuj�� na wi�ksz� skal�

%% Przygotowanie do wykonania skryptu, wst�pne czyszczenie konsoli, zmiennych, otwartych okien
clear; close all; clc;

%% Przypisanie odpowiednich w�a�ciwo�ci sieci
AmountOfNodes=int16.empty;
while isempty(AmountOfNodes) 
    AmountOfNodes = input(' Enter number of nodes: '); % np. 30; % Liczba przyj�tych w�z��w
    while AmountOfNodes<=0 
        AmountOfNodes = input(' Enter proper number of nodes: ');
    end
end
AmountOfLinks=int16.empty;
while isempty(AmountOfLinks) 
    AmountOfLinks = input(' Enter number of links: ');% np. 130; % Liczba przyj�tych kana��w
    while AmountOfLinks<=0
        AmountOfLinks = input(' Enter proper number of links: ');
    end
end
% Macierz wag wszystkich kanalow z  losowymi warto�ciami z zakresu: 1-(liczba w�z��w)
throughput = round(99*rand(1,AmountOfLinks))+1;
cost = round(99*rand(1,AmountOfLinks))+1; % Wagi w�z��w (odleg�o�ci w�z��w)
% Pocz�tek i koniec kana��w wszystkich kanal�w (Utworzenie kana��w) z zakresu: 1-(liczba w�z��w)
source=round((AmountOfNodes-1)*rand(1,AmountOfLinks))+1;
target_nodes=round((AmountOfNodes-1)*rand(1,AmountOfLinks))+1;

% Nazwy w�z��w utworzymy w p�tli poprzez stworzenie 'Nr?", gdzie ? to numer w�z�a
names=string.empty(0,AmountOfNodes);
 for x=AmountOfNodes:-1:1
     NodeIndex=convertCharsToStrings(['Nr',num2str(x)]);
     names(x)=NodeIndex;
 end 
 
% Utworzenie grafu sieci rezydualnej, ignorujemy "samop�tle"
ResidualGraph = digraph(source,target_nodes,throughput,names,'omitselfloops'); 
% Usuwamy wielokrotne kana�y, je�li takie istniej� i zast�piamy pojedynczymi
if ismultigraph(ResidualGraph)
    ResidualGraph = simplify(ResidualGraph,'sum'); 
end

% Przed rozpocz�ciem algorytmu szukania �cie�ek musimy wybra� �r�d�a oraz
% uj�cia danej sieci w celu jej optymalizacji. Z grafu wiemy, �e :
% AmountOfNodes % <-- ilo�� w�z��w wynosi:
% AmountOfLinks % <-- ilo�� kana��w wynosi:
% names % <-- nazwy wygl�daj� nast�puj�co
% Wybierzemy losowe dla �r�de� np. 5 w�z��w, oraz dla uj�� i oczekiwany przep�yw pomi�dzy nimi.
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
ChosenSources = randperm(AmountOfNodes,AmountOfSources); % losowe �r�d�a z zakresu: 1-(liczba w�z��w) bez powt�rze�
ChosenTargets = randperm(AmountOfNodes,AmountOfTargets); % losowe uj�cia z zakresu: 1-(liczba w�z��w) bez powt�rze�

%% Dzia�anie algorytmu Forda-Folkursona

% Macierz wagowa (s�siedztwa) danego grafu rezydualnego:
AdjadencyWeightMatrix = full(adjacency(ResidualGraph,'weighted')) ; 

% Dodamy super�r�d�o, superuj�cie oraz podpiszemy je
NamesForNewNodes = {'SuperSource', 'SuperTarget'};
NewResidualgraph = addnode(ResidualGraph,2);
NewResidualgraph.Nodes.Name(size(NewResidualgraph.Nodes,1)-1:end) = NamesForNewNodes;

% Dodamy odpowiednie kana�y i ich przepustowo�ci rezydualne dla super�r�d�a
NewResidualgraph = addedge(NewResidualgraph, {'SuperSource'},NewResidualgraph.Nodes.Name(ChosenSources), ...
    sum(AdjadencyWeightMatrix(ChosenSources,:),2)); % <-- przepustowo�ci rezydualne kolejnych "��cznik�w"

% Dodamy odpowiednie kana�y i ich przepustowo�ci rezydualne dla superuj�cia
NewResidualgraph = addedge(NewResidualgraph, NewResidualgraph.Nodes.Name(ChosenTargets),{'SuperTarget'}, ...
    sum(AdjadencyWeightMatrix(:,ChosenTargets))); % <-- przepustowo�ci rezydualne kolejnych "��cznik�w"

% % Ewentualny rysunek
% NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight);
% L0Widths=find(NewResidualLWidths==0);
% NewResidualgraph=rmedge(NewResidualgraph,L0Widths); NewResidualLWidths(L0Widths)=[];
% if (~isempty(NewResidualLWidths)) 
%     plot(NewResidualgraph,'EdgeLabel',NewResidualgraph.Edges.Weight,'LineWidth',...
%         NewResidualLWidths,'NodeColor','black','EdgeColor','blue','MarkerSize',7);
% end

% Na zmodyfikowanym grafie mo�emy azcz�� szuka� ju� �cie�ek roszerzaj�cych 
% mi�dzy super�r�d�em, a superuj�ciem korzystaj�c z algorytmu Edmondsa-Karpa.

% W pierwszym kroku zadania zerujemy kana�y sieci przep�ywowej, oraz szukamy najkr�tszej �cie�ki rozszerzaj�cej 
% (sieci rezydualnej) ze super�r�d�a do superuj�cia, bior�c pod uwag� jedynie ilo�� kana��w po drodze
FlowGraph = NewResidualgraph; FlowGraph.Edges.Weight(:)= 0;

% Nast�pnie poszukujemy �cie�ek rozszerzaj�cych (je�li istniej�) dla
% tego samego w�z�a pocz�tkowego i ko�cowego (i,j) oraz analogicznie
% wykonujemy dalsze czynno�ci. Je�li nie mo�emy ich znale��, wy�wietlimy zoptymalizowany graf.
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
       
        % Dla sieci przep�ywowej identyfikatory odpowiednich kana��w nie b�d� identyczne z powodu zmiany kierunku �cie�ki. 
        % Utworzymy wi�c na niej wielokrotne kraw�dzie, a nast�pnie upro�cimy je tworz�c ich sum�.
        
        % Zwi�kszamy odpowiednie warto�ci
        for i=1:(length(ShortestPathOfBuiltGraph)-1)
            FlowGraph = addedge(FlowGraph, ShortestPathOfBuiltGraph(i),ShortestPathOfBuiltGraph(i+1), NewFlow);
            FlowGraph = simplify(FlowGraph,'sum');
        end
        
        % Usuwamy kana�y zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
        NewResidualgraph = rmedge(NewResidualgraph,find(NewResidualgraph.Edges.Weight==0));   
    end
end

% Doszli�my do etapu, w kt�rym nie mo�emy znale�� �cie�ki rozszerzaj�cej.
% Przep�yw nie mo�e by� ju� bardziej zwi�kszony, a wi�c poka�emy otrzymane rezultaty 
% (po usuni�ciu kana��w wyschni�tych w grafie rezydualnym, przep�ywu, pomocniczym):
numbers = find(ResidualGraph.Edges.Weight==0);
ResidualGraph=rmedge(ResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight); % Szeroko�� kana�u na rysunku

numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
FlowLWidths = 2*FlowGraph.Edges.Weight/max(FlowGraph.Edges.Weight); % Szeroko�� kana�u na rysunku

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

%% Dzia�anie algorytmu Busackera-Gowena

% Skorzystamy z utworzonych na pocz�tku graf�w i wizualizacji, oraz utworzymy nowy graf sieci koszt�w
CostGraph = digraph(source,target_nodes,cost,names,'omitselfloops'); % Utworzenie grafu sieci koszt�w
% Usuwamy wielokrotne kana�y, je�li takie istniej� i zast�piamy pojedynczymi
if ismultigraph(CostGraph)
    CostGraph = simplify(CostGraph,'sum'); 
    % Waga pozostawionej kraw�dzi r�wna jest sumie wag kraw�dzi w niej zawartych
end

% Macierz wagowa (s�siedztwa) danego grafu rezydualnego:
AdjadencyWeightMatrix = full(adjacency(ResidualGraph,'weighted')) ; 

% Dodamy super�r�d�o, superuj�cie oraz podpiszemy je. 
% Przyjmiemy umownie, �e koszt kana��w wychodz�cych/wchodz�cych z nimi powi�zanymi wynosi 0.
ResidualGraph = addnode(ResidualGraph,2);
NewCostgraph = addnode(CostGraph,2);
ResidualGraph.Nodes.Name(size(ResidualGraph.Nodes,1)-1:end) = {'SuperSource', 'SuperTarget'};
NewCostgraph.Nodes.Name(size(NewCostgraph.Nodes,1)-1:end) = {'SuperSource', 'SuperTarget'};

CostOfSuperSources = zeros(1,AmountOfSources); 
CostOfSuperTargets = zeros(1,AmountOfTargets);
% Dodamy odpowiednie kana�y i ich przepustowo�ci rezydualne dla super�r�d�a w grafie sieci rezydualnej i koszt�w
NewResidualgraph = addedge(ResidualGraph, {'SuperSource'},ResidualGraph.Nodes.Name(ChosenSources), ...
    sum(AdjadencyWeightMatrix(ChosenSources,:),2)); % <-- przepustowo�ci rezydualne kolejnych "��cznik�w"
NewCostgraph = addedge(NewCostgraph, {'SuperSource'},NewCostgraph.Nodes.Name(ChosenSources),CostOfSuperSources); % <-- koszty "��cznik�w"

% Dodamy odpowiednie kana�y i ich przepustowo�ci rezydualne dla superuj�cia
NewResidualgraph = addedge(NewResidualgraph, NewResidualgraph.Nodes.Name(ChosenTargets),{'SuperTarget'}, ...
    sum(AdjadencyWeightMatrix(:,ChosenTargets))); % <-- przepustowo�ci rezydualne kolejnych "��cznik�w"
NewCostgraph = addedge(NewCostgraph, NewCostgraph.Nodes.Name(ChosenTargets),{'SuperTarget'},CostOfSuperTargets); % <-- koszty "��cznik�w"
% 
% % Ewentualna wizualizacja zmodyfikowanych graf�w sieci koszt�w i grafu sieci rezydualnej
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

% Na zmodyfikowanym grafie mo�emy zacz�� szuka� ju� �cie�ek roszerzaj�cych 
% mi�dzy super�r�d�em, a superuj�ciem korzystaj�c z algorytmu Busackera-Gowena.

% W pierwszym kroku zadania zerujemy kana�y sieci przep�ywowej, oraz szukamy najkr�tszej �cie�ki rozszerzaj�cej 
% (sieci rezydualnej) ze super�r�d�a do superuj�cia, bior�c pod uwag� jedynie ilo�� kana��w po drodze
FlowGraph = NewResidualgraph; FlowGraph.Edges.Weight(:)= 0;

% Musimy uwzgl�dni� tak�e, �e wyznaczone p�niej najkr�tsze trasy nie mog� zawiera� 
% kana��w uschni�tych grafu sieci rezydualnej. Dla uproszczenia utworzymy pomocniczy graf
% na podstawie grafu koszt�w, jednak bez wspomnianych kana��w. Nast�pnie za jednym
% razem usuniemy wi�c odpowiednie kana�y w grafie rezydualnym i pomocniczym
SmallerCostGraph = NewCostgraph; % Utworzenie pomocniczego grafu (koszt�w)

% Nast�pnie wracamy do poszukiwania dalszych �cie�ek rozszerzaj�cych (je�li istniej�) dla
% tego samego w�z�a pocz�tkowego i ko�cowego (i,j) oraz analogicznie
% wykonujemy dalsze czynno�ci. Je�li nie mo�emy ich znale��, wy�wietlimy
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
       
        % Dla sieci przep�ywowej identyfikatory odpowiednich kana��w nie b�d� identyczne z powodu zmiany kierunku �cie�ki. 
        % Utworzymy wi�c na niej wielokrotne kraw�dzie, a nast�pnie upro�cimy je tworz�c ich sum�.
        
        % Zwi�kszamy odpowiednie warto�ci
        for i=1:(length(ShortestPathOfBuiltGraph)-1)
            FlowGraph = addedge(FlowGraph, ShortestPathOfBuiltGraph(i),ShortestPathOfBuiltGraph(i+1), NewFlow);
            FlowGraph = simplify(FlowGraph,'sum');
        end
        
        % Usuwamy kana�y zb�dne(z zerow� przepustowo�ci�) powsta�e w wyniku poprzednich operacji
        SmallerCostGraph = rmedge(SmallerCostGraph,find(NewResidualgraph.Edges.Weight==0));  
        NewResidualgraph = rmedge(NewResidualgraph,find(NewResidualgraph.Edges.Weight==0));   
    end
end

% Doszli�my do etapu, w kt�rym nie mo�emy znale�� �cie�ki rozszerzaj�cej.
% Przep�yw nie mo�e by� ju� bardziej zwi�kszony, a wi�c poka�emy otrzymnae rezultaty 
%(po usuni�ciu kana��w wyschni�tych w grafie rezydualnym, przep�ywu, pomocniczym):
numbers = find(ResidualGraph.Edges.Weight==0);
ResidualGraph=rmedge(ResidualGraph,numbers);
NewResidualLWidths = 2*NewResidualgraph.Edges.Weight/max(NewResidualgraph.Edges.Weight); % Szeroko�� kana�u na rysunku

numbers = find(FlowGraph.Edges.Weight==0);
FlowGraph=rmedge(FlowGraph,numbers);
FlowLWidths = 2*FlowGraph.Edges.Weight/max(FlowGraph.Edges.Weight); % Szeroko�� kana�u na rysunku
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