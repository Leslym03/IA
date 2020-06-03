
#include <list>
#include <algorithm>


class Graph{
    int V;
    list<int> *adj;
public:
    Graph(int V);
    ~Graph();
    void addEdge(int u,int v);
    void BFS(int src);
};
Graph::Graph(int V){
    this->V = V;
    adj = new list<int>[this->V];
}
Graph::~Graph(){
    delete [] adj;
}

void Graph::addEdge(int u,int v){
    adj[u].push_back(v);
    adj[v].push_back(u);
}
void Graph::BFS(int src){
    vector <int> dist(this->V,0);
    vector <int> parent(this->V,-1);
    vector <bool> visited(this->V,false);

    queue<int> Q;
    dist[src] = 0;
    visited[src] = true;
    Q.push(src);

    list<int>::iterator it;

    while(!Q.empty()){
        int u = Q.front();
        Q.pop();
        for(it = adj[u].begin();it!=adj[u].end();++it){
            int v = *it;
            if(!visited[v]){
                dist[v] = dist[u] + 1;
                parent[v] = u;
                visited[v] = true;
                Q.push(v);
            }
        }
    }
}
