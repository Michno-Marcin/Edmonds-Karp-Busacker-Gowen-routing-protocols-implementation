# Edmonds-Karp-Busacker-Gowen-routing-protocols-implementation

This project is a Matlab implementation of the Edmonds-Karp and Busacker-Gowen algorithms for finding maximum flow at minimum cost in networks.

By checking the "ApplicationOfMethodSupersourcesSupertargets.m" script and running consecutive lines with comments, you can see the idea of supersources and supertargets in practice.
By checking the "EdmondsKarp_and_BusackerGowen_Example.m" script and running consecutive lines containing comments, you can see the idea of both routing protocols.

As illustrated in the first figure, the shortest extension path of the residual graph in terms of the number of channels is shown in red with green vertices.
<p align="center">
  <img src="https://github.com/user-attachments/assets/7072be1a-eace-4b94-bd8c-61297aca155f" width="40%" height="40%"/>
</p> 
The second figure illustrates the graph of a fully optimised flow network.
<p align="center">
  <img src="https://github.com/user-attachments/assets/ff4508bc-f793-4ae5-8fa4-f299c2b6e254" width="40%" height="40%" />
</p>

Both mentioned scripts contain example network parameters. The final result can be seen in the final script "LargeNetworkOptimization.m". You can run it, enter sample values and see the effect. 
An example of the final result using the Busacker-Gowen algorithm is shown below.
<p align="center">
  <img src="https://github.com/user-attachments/assets/bf49b1aa-f117-4def-868a-45bf9c2e3d0f" width="50%" height="50%" />
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/20fe332d-6788-485b-9fa6-e24658c1da4b" width="50%" height="50%"/>
</p>