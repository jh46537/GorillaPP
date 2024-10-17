/*
Implementation based on:
Hong, Oguntebi, Olukotun. "Efficient Parallel Graph Exploration on Multi-Core CPU and GPU." PACT, 2011.
*/

#include "bfs.h"
#include "../../common/primate-hardware.hpp"

#define Q_PUSH(node) { queue[q_in==0?N_NODES-1:q_in-1]=node; q_in=(q_in+1)%N_NODES; }
#define Q_PEEK() (queue[q_out])
#define Q_POP() { q_out = (q_out+1)%N_NODES; }
#define Q_EMPTY() (q_in>q_out ? q_in==q_out+1 : (q_in==0)&&(q_out==N_NODES-1))

void bfs(node_t nodes[N_NODES], edge_t edges[N_EDGES],
            node_index_t starting_node, level_t level[N_NODES],
            edge_index_t level_counts[N_LEVELS])
{
  node_index_t queue[N_NODES];
  node_index_t q_in, q_out;
  node_index_t dummy;
  node_index_t n;
  edge_index_t e;

  /*init_levels: for( n=0; n<N_NODES; n++ )*/
  /*level[n] = MAX_LEVEL;*/
  /*init_horizons: for( i=0; i<N_LEVELS; i++ )*/
  /*level_counts[i] = 0;*/

  q_in = 1;
  q_out = 0;
  level[starting_node] = 0;
  level_counts[0] = 1;
  Q_PUSH(starting_node);

  loop_queue: for( dummy=0; dummy<N_NODES; dummy++ ) { 
    if( Q_EMPTY() )
      break;
    n = Q_PEEK();
    Q_POP();
    edge_index_t tmp_begin = nodes[n].edge_begin;
    edge_index_t tmp_end = nodes[n].edge_end;
    loop_neighbors: for( e=tmp_begin; e<tmp_end; e++ ) {
      node_index_t tmp_dst = edges[e].dst;
      level_t tmp_level = level[tmp_dst];

      if( tmp_level ==MAX_LEVEL ) { // Unmarked
        level_t tmp_level = level[n]+1;
        level[tmp_dst] = tmp_level;
        ++level_counts[tmp_level];
        Q_PUSH(tmp_dst);
      }
    }
  }

  /*
  printf("Horizons:");
  for( i=0; i<N_LEVELS; i++ )
    printf(" %d", level_counts[i]);
  printf("\n");
  */
}

// int main() {
//   node_t nodes[N_NODES] = PRIMATE::input<node_t>();
//   edge_t edges[N_EDGES] = PRIMATE::input<edge_t>();
//   node_index_t starting_node = PRIMATE::input<node_index_t>;
//   level_t level[N_NODES] = PRIMATE::input<level_t>();
//   edge_index_t level_counts[N_LEVELS] = PRIMATE::input<edge_index_t>();
//   bfs(nodes, edges,
//       starting_node, level,
//       level_counts);
// }

void primate_main() {
  bench_args_t args = PRIMATE::input<bench_args_t>();
  PRIMATE::input_done();
  bfs(args.nodes, args.edges, args.starting_node, 
      args.level, args.level_counts);
  PRIMATE::output(args.starting_node);  // probably wrong
  PRIMATE::output_done();
}
