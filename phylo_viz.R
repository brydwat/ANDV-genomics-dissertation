##### Contains 5 independent scripts used for MSc thesis.
##### The final publication graphic
##### A rough visual plot of nodes to visually guide lineage-finding
##### A function to trace and list all lineages from the node to each tip.
##### A function to find MSA entropy and produce a graphic for the M-segment
##### A quick and rough ggtree phylo visualization.

library(ggtree)
library(treeio)
library(ggplot2)
library(dplyr)
library(readxl)
library(ape)
library(TDbook)
library(patchwork)
library(ggbreak)
library(RColorBrewer)

# Set working directory
setwd("C:/Users/zhiva/Files/UoG Courses/BIOL 5173P - MSc Thesis Project")

### ------------------------------ FINAL TREE ------------------------------ ###
# Final MSc thesis phylogeny plots.
# Needs re-tooling depending on segment input.
# Some guide data stored in comments.

# Import tree data.
phy <- read.newick("cured_data/trees/ANDV_M/ANDV_M_fin2_phy.treefile")

# OPTIONAL: Choose 1 sequence to root
# Commonly used ANDV outgroups below.
  # NC_003466.1 - S Reference
  # NC_003467.2 - M Reference
  # NC_003468.2 - L Reference

# OR908896.1 - reservoir outgroup for S
  # OR987856.1 - reservoir outgroup for M
  # - reservoir outgroup for L

root_seq = "OR987856.1"

# Set root outgroup and pass to tree_obj
nuc_rooted <- root(
  phy,
  outgroup = root_seq,
  resolve.root = TRUE
)

# Import tree metadata.
data_path <- "cured_data/ANDV_M_metadata.csv"
metadata <- read.csv(data_path)

#metadata_prot <- read.csv("ANDV_M_metadata_prot.csv")

# Rename accession column to 'label' (Change column based on accession ID used in phylos)
colnames(metadata)[colnames(metadata) == "Accession"] <- "label"

# OPTIONAL - prune outgroup and pass to tree_obj
pruned_tree <- drop.tip(nuc_rooted, tip = c("OR987856.1"))
tree_obj <- ggtree(pruned_tree, layout = "rectangular", branch.length = "0.1") %<+% metadata

# Misc variables for plot

# Custom factored palette - first ignore blank cells.
metadata$Outbreak[metadata$Outbreak == ""] <- NA
outbreak_levels <- sort(unique(na.omit(metadata$Outbreak)))

outbreak_palette <- c(
  "AREB/14"      = "maroon2",
  "CHI-DLR/24"   = "darkorchid1",
  "CHI/1999"     = "firebrick3",
  "Epilink/96"   = "gold",
  "Epuyen/18-19" = "indianred1",
  "Hondius/26"   = "orange1",
  "LS-CH2016"    = "olivedrab2",
  "NRC"          = "steelblue1",
  "Reservoir"    = "paleturquoise1"
)
# FINAL ANNOTATED TREE
final_plot <- tree_obj +
  geom_label2(data = function(x) subset(x, isTip),
              aes(label = label, fill = Outbreak), 
              color = "black", size = 3, 
              label.padding = unit(.2, "lines"),
              hjust = -0.1, label.size = 0) +
  scale_fill_manual(values = outbreak_palette, name = "Outbreak") +
  guides(fill = guide_legend(override.aes = list(label = "   "))) +
  # geom_text(aes(label=node), hjust=-.3) + #SHOWS NODE NUMBER.
  # COLOR NODES BY BOOTSTRAP SUPPORT
  geom_nodepoint(aes(subset = as.numeric(label) >= 90), color = "black", size = 1.5) +
  geom_nodepoint(aes(subset = as.numeric(label) < 90 & as.numeric(label) >= 70), color = "goldenrod1", size = 1.5) +
  geom_nodepoint(aes(subset = as.numeric(label) < 70 & as.numeric(label) >= 50), color = "firebrick2", size = 1.5) +
  geom_nodepoint(aes(subset = as.numeric(label) < 50), color = "darkorchid3", size = 1.5) +
  geom_treescale(x = 0.05, y = -1.5, width = 0.05) +   # Scale bar proportional to substitution distance
  geom_rootedge(rootedge = 0.005) +
  
  # CLADE ANNOTATIONS
  geom_cladelab(node = 35, label = "PTP Clade",
                align = TRUE, offset = 0.023, offset.text = -0.005,
                barsize = 2.5, angle = 90, hjust = 0.5,
                textcolor = 'indianred2', barcolor = 'indianred2') + # coral
  geom_cladelab(node = 37, label = "Clade 1",
                align = TRUE, offset = 0.025, offset.text = 0.0029,
                barsize = 2.5, angle = -90, hjust = 0.5,
                textcolor = 'lightcyan3', barcolor = 'lightcyan3') + # bisque1
  geom_cladelab(node = 55, label = "Clade 2",
                align = TRUE, offset = 0.025, offset.text = 0.0029,
                barsize = 2.5, angle = -90, hjust = 0.5,
                textcolor = 'lightsteelblue1', barcolor = 'lightsteelblue1') + # navajowhite1
  geom_cladelab(node = 45, label = "Clade 3",
                align = TRUE, offset = 0.025, offset.text = 0.0029,
                barsize = 2.5, angle = -90, hjust = 0.5,
                textcolor = 'ivory3', barcolor = 'ivory3') + # lightgoldenrod1
  # PRESERVED HOLDOVERS FROM S PHYLO WHICH HAS MORE CLADES
  #geom_cladelab(node = 10, label = "Clade 4",
  #              align = TRUE, offset = 0.025, offset.text = 0.0029,
  #              barsize = 2.5, angle = -90, hjust = 0.5,
  #              textcolor = 'slategray1', barcolor = 'slategray1') + # peachpuff2
  #geom_cladelab(node = 20, label = "Clade 5",
  #              align = TRUE, offset = 0.025, offset.text = 0.0029,
  #              barsize = 2.5, angle = -90, hjust = 0.5,
  #              textcolor = 'lightblue1', barcolor = 'lightblue1') + # rosybrown1


  
  #geom_hilight(node = 90, fill = "steelblue", alpha = 0.2) +
  coord_cartesian(xlim = c(-0.01, 0.1), ylim = c(-1.5, 32), clip = "off") +
  ggtitle("ANDV - Medium (M) segment") +
  theme(plot.title = element_text(hjust = 0.6))
  #theme(legend.position="none")

print(final_plot)

#final_plot <- rotate(final_plot, 59) # Only leave for wide L tree


### --------------------------- VISUAL NODE PLOT --------------------------- ###
# Creates plot with labelled nodes and tips to give a rough 
# visualization of the nodes produced from an inferred tree.
# Used to plan or identify node paths and select the root
# sequences of interest for DMS or additional processing.

# Needs a NEXUS output file from TreeTime, BEAST, or IQTree3

# Load the .nexus filet
node_tree_tt <- read.beast("timetree_S.nexus")
phy <- node_tree_tt@phylo

# Set Most Recent Sampling Date (most recent sequence) - can't parse iqtree output yet
# Hondius/26 (Swiss) is most recent sample
mrsd_value <- 2026.340000

# OPTIONAL - prune outgroup
pruned_tree <- treeio::drop.tip(node_tree_tt, tip = c("OR908896.1"))  # or whatever tips descend from that ancestor
  
# Plot to list ancestral nodes
node_plot <- ggtree(phy) +
  geom_tiplab(size = 3, align = FALSE) +                       # Tip names
  geom_nodepoint(color = "steelblue", size = 3, alpha = 0.6) + # Internal node markers
  geom_text2(aes(subset = !isTip, label = label),              # Internal node labels
             hjust = 1, vjust = 1, 
             size = 3, color = "darkred") +
  xlim(0.1, 525) +
  ylim(-0, 30) +
  ggtitle("ANDV S Ancestral Node trace (ORNV cut)") +
  theme(plot.title = element_text(hjust = 0.5))

print(node_plot)


### ---------------------------- Lineage Trace ----------------------------- ###
# Finds and lists parent-child lineages along each tip's path.
# Outputs lists of each lineage from tip to root.

library(ape)

# Read nexus file of inferred ancestry
phy <- read.nexus("C:/Users/zhiva/Files/UoG Courses/BIOL 5173P - MSc Thesis Project/cured_data/ancestries/tt_anc_ANDV_M.2/timetree.nexus")

# List of all tips and nodes
all_labels <- c(phy$tip.label, phy$node.label)

# N tips and the root index. By ape convention, node N + 1
total_tips <- Ntip(phy)
root_indx <- total_tips + 1

# Initiate list to name lineages
all_lineages_list <- list()

# Loop over phylogeny tips, get nodepath {ape} from each one.
for (i in 1:total_tips) {
  tip_id <- phy$tip.label[i]
  
  # Fetch path for tip [i] directly Root to tip
  lineage_path <- nodepath(phy, from = root_indx, to = i)
  
  # With list of labels tip and node, add subset of this lineage
  # to the list of all lineages.
  all_lineages_list[[tip_id]] <- all_labels[lineage_path]
}

# Show lineages for each tip
print(all_lineages_list)      


### --------------------------- Entropy Scores ----------------------------- ###
# Computes entropy of a protein MSA and 
# prints a graphical overview of the entropy found in a protein
# Custom subunits built in for M segment.

library(bio3d)
#library(Bios2cor)

alignment <- read.fasta("cured_data/prot_ANDV_Mfin.fasta")
# con.ANDV_M <- consensus(alignment) # Used with Bios2cor

# Compute shannon entropy at each column
entropy_obj <- entropy(alignment)
entropy_diverse <- entropy_obj$H

# --- Build Plot Dataframe --- #

df <- data.frame(
  position = seq_along(entropy_diverse),
  entropy  = entropy_diverse
)

# Define domain boundaries
df$domain <- ifelse(df$position <= 649, "Gn", "Gc")

# ------- Entropy Plot ------- # 

domain_labels <- data.frame(
  domain = c("Gn", "Gc"),
  position = c(649 / 2, (649 + max(df$position)) / 2))

domain_bar <- ggplot(df, aes(x = position, y = 1, fill = domain)) +
  geom_tile() +
  scale_fill_manual(values = c(Gn = "indianred2", Gc = "steelblue")) +
  geom_text(
    data = domain_labels,
    aes(x = position, y = 1, label = domain),
    color = "white",
    fontface = "bold"
  ) +
  theme_void() +
  theme(legend.position = "none")

entropy_plot <- ggplot(df, aes(x = position, y = entropy, color = domain)) +
  geom_col(width = 1) +
  scale_color_manual(values = c(Gn = "indianred2", Gc = "steelblue")) +
  labs(x = "Position", y = "Alignment Entropy") +
  theme_minimal() +
  theme(legend.position = "none")

# With bar annotation
domain_bar / entropy_plot + plot_layout(heights = c(1, 8))


### ------------------------------ QUICK TREE ------------------------------ ###
ml_tree <- read.newick("ANDV_M_nuc_phylo1.treefile")

# Plot with true branch lengths
ggtree(ml_tree) + 
  geom_tiplab(size = 3) + 
  # Display bootstrap values only for nodes that have them and where support is > 70
  geom_nodelab(aes(label = label), hjust = -.2, size = 2.5) +
  theme_tree2()