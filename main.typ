// Some definitions presupposed by pandoc's typst output.
#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]
#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

#set table(
  inset: 6pt,
  stroke: none
)

// #show figure.where(
//   kind: table
// ): set figure.caption(position: top)

// #show figure.where(
//   kind: image
// ): set figure.caption(position: bottom)

#import "sty/yongfu.typ": *
#import "sty/ams.typ": *  // #import "lib.typ": *
// #import "@local/ams:1.0.0": *
// #import "@preview/unequivocal-ams:0.1.1": *

#show: ams-article.with(
  title: [A Preliminary Model for Joint Inference of Hearing Conditions and Age Thresholds],
  short_title: [Inferring Hearing Conditions and Age Thresholds],
  date: "November 23, 2024",
  authors: (
            ( 
              name: "Yongfu Liao",
              organization: [Children’s Hearing Foundation],
              location: [Taipei, Taiwan],
              email: "tomliao@chfn.org.tw",
              url: "https://yongfu.name"
            ),
  ),
  // bibliography: "refs.bib",
)


// Custom styles
#set std-bibliography(style: "american-psychological-association", title: [References])
#set par.line(numbering: "1")
#set math.equation(numbering: "(1)")

#show ref: it => {
  let eq = math.equation
  let el = it.element
  if el != none and el.func() == eq {
    // Override equation references.
    link(el.location(),numbering(
      el.numbering,
      ..counter(eq).at(el.location())
    ))
  } else {
    // Other references as usual.
    it
  }
}
// Center image & box
#show box: it => {
  align(center, it)
}
// Table
#show table.cell.where(y: 0): strong
#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
  align: (x, y) => (
    if x > 0 { left }
    else { left }
  )
)
// #import "@local/yongfu:1.0.0": *  // for exporting to markdown
#import "@preview/ouset:0.2.0": overset, underset  // \underset{} for typst

= Introduction <introduction>
Constructing items for assessing and diagnosing young children can be challenging due to the rapid pace of cognitive and neuromuscular development during this stage. Typically, in a scale designed for such purposes, the latent conditions of interest are assumed to be signaled by the presence (or absence) of certain behaviors as indicated by the scale’s items. However, this assumption may not hold when assessing very young children, as the presence of a behavior could depend more on the child's development than their latent condition. For example, consider items for detecting hearing loss in children. In such a case, an item like "My child often fails to understand long sentences" is only valid for detecting hearing loss in children who have developed the cognitive competence for understanding longer sentences. Therefore, to correctly infer a child’s latent condition, it is essential to also consider their developmental status.

To address this, we developed a model that accounts for the influences of both development and latent conditions on item responses. The model enables one to (a) estimate the age boundaries within which items are valid and (b) classify individuals into binary conditions by weighing information across items according to their age.

= Motivating Context <motivating-context>
We begin by describing four types of items whose discriminative power (i.e., validity) changes with development, for which we use child age as a proxy. The subplots in @age-pattern correspond to the four item types, each specifying the relationship between child age and the probability of a "Yes" response#footnote[For the sake of illustration, it is assumed here that no item response needs reverse coding. That is, assuming the items are valid, the presence of hearing loss ($z = 1$) always leads to higher probabilities of "Yes" responses, compared to "No" responses, for all items.]. The red curves plot the trajectories of children with hearing loss ($z = 1$) across ages, whereas the blue curves plot the trajectories for children with typical hearing ($z = 0$). Type-1 and Type-2 items (top row in Figure 1) represent items that are valid for discriminating hearing loss from typical hearing only _above_ a certain age threshold, as there is minimal difference between children in the two conditions at younger ages. In contrast, Type-3 and Type-4 items are valid _below_ a certain age threshold, often reflecting behaviors that fade out as children mature, such as startle reflexes and breastfeeding-related behaviors. Some hypothetical items are provided at the bottom of the subplots in @age-pattern.

#figure(image("figs/item_type.png", width: 93%),
  caption: [
    The four types of age-restricted items addressed in this manuscript. The horizontal axes in the plots represent child development, with age used as a proxy. The vertical axes represent the probability of a "Yes" item response. The red lines graph the trajectories of hearing loss ($z=1$) children, and the blue lines represent typical hearing ($z=0$) children. The four item types are therefore defined by two independent properties: (a) whether an item becomes discriminative (i.e., valid) _below_ or _above_ the age threshold, and (b) whether an invalid item results uniformly in a _high_ or _low_ probability of a "Yes" response in different groups.
  ]
)
<age-pattern>

= Model Specification <model>
With the four item types in mind, we now introduce our model. The model's logic is illustrated in the tree diagrams in @tree, which represent the (idealized) data-generating processes that map a child onto an expected item response according to two latent variables, $k$ and $z$. The variable $k$ specifies the _discriminative power_ (validity) of an item given a child’s age, where $k = 1$ indicates maximal discrimination, and $k = 0$ indicates no discrimination. The variable $z$ denotes a child's latent condition, which, in this context, is either hearing loss ($z = 1$) or typical hearing ($z = 0$). Thus, $k$, $z$, and the item's age-dependent response pattern codetermine the expected item response. Specifically, the left tree diagram depicts the data-generating process for Type-1 and Type-3 items (the left column in @age-pattern), while the right diagram depicts the process for Type-2 and Type-4 items (the right column in @age-pattern). For instance, one would expect a "Yes" response when the item is discriminative ($k=1$) and the child has hearing loss ($z=1$). However, if the item is non-discriminative ($k=0$), a similar response would be expected regardless of the child’s hearing condition. The description so far is _idealized_ and _deterministic_; in practice, noise is expected. Therefore, at the bottom of the tree diagrams, we list the probability of a "Yes" response for each condition modeled. These probabilities correspond to the model's parameters, which we now turn to.

#figure(
  // image("figs/tree_combine.png", width: 103%),
  grid(
      columns: (auto, auto),
      rows:    (auto, auto),
      column-gutter: 15pt,
      row-gutter: 4pt,
      [ #image("figs/dgm_tree.svg",  height: 15.8em) ],
      [ #image("figs/dgm_tree2.svg", height: 15.8em) ],
  ),
  placement: bottom,
  caption: [
    Idealized data-generating processes mapping a child to an expected item response according to the discriminative power $k$ and hearing condition $z$. The left diagram corresponds to the process for Type-1 and Type-3 items, and the right diagram for Type-2 and Type-4 items. The terms at the bottom represent probabilistic versions of the corresponding idealized item responses to account for noise in real data.
  ]
)
<tree> 

#h(1.2em) In our model, we used the Bernoulli distribution to link a binary item response $up(Y)_(i,j)$, collected from item $j$ for child $i$, to an underlying probability $p$. 

#set math.equation(numbering: none)
$
up(Y)_(i,j) & ~ "Bernoulli"(p)
$

The probability $p$ is determined by the item parameters $S_j$, $G_j$, and $gamma_j$, the child’s latent condition parameter $z_i$, the discriminative power $k$, and the item type, as shown below.

$
p & = cases(
            (1 - S_j)^(z_i k)
            G_j^((1-z_i)k)
            (1 - gamma_j)^(1-k) & script("[Type-1 & Type-3 items]"), 

            (1 - S_j)^(z_i k)
            G_j^((1-z_i)k)
            gamma_j^(1-k)       & script("[Type-2 & Type-4 items]") , 
          )
$

The terms making up $p$ essentially formalize the relationships represented in the tree diagrams in @tree. By specifying the item type and substituting combinations of $0$ and $1$ for $z_i$ and $k$ (e.g., $z_i=1$ and $k=0$) into the above equation, $p$ simplifies to a term corresponding to one of the eight probabilities at the bottom of @tree. 

The item parameters $S_j$, $G_j$, and $gamma_j$ model deviations from ideal probabilities of $1$ or $0$. Specifically, $S_j$ and $G_j$ can be respectively thought of as the false-negative rate (or, $1 - "sensitivity"$) and the false-positive rate (or, $1 - "specificity"$) in a signal-detection context, or as the "slip" and "guess" parameters in diagnostic classification models @rupp2010.

To link the discriminative power $k$ to child age, $k$ is modeled as a function of age and the item age threshold parameter $delta_j$. The function is set up so that, as the difference between the child's age and the item age threshold increases, $k$ approaches either $0$ or $1$, depending on the item type. How fast $k$ approaches $0$ and $1$ is governed by the parameter $D$ (fixed across items), akin to the discrimination parameter in traditional item response models. 

$
  k & = cases( 
            "logit"^(-1)( D("Age"_i - delta_j) ) #h(48pt) & script("[Type-1 & Type-2 items]"),
            "logit"^(-1)( D(delta_j - "Age"_i) )          & script("[Type-3 & Type-4 items]"),
          )
$

Note that in the discussion of the data-generating process in @tree, $k$ is assumed to be binary for simplicity. From here on, we treat $k$ as continuous and bounded between $0$ and $1$.

By collecting the terms above and including age-unrestricted items, we arrive at the full model in @model-spec. The final term, $z_i ~ "Bernoulli"(pi)$, indicates that the latent condition $z_i$ is generated from an underlying prevalence parameter $pi$.

#set math.equation(numbering: "(1)")
$
up(Y)_(i,j)  & ~ "Bernoulli"(p) \
          p & = cases(
            (1 - S_j)^(z_i k)
            G_j^((1-z_i)k)
            (1 - gamma_j)^(1-k) & script("[Type-1 & Type-3 items]"), 

            (1 - S_j)^(z_i k)
            G_j^((1-z_i)k)
            gamma_j^(1-k)       & script("[Type-2 & Type-4 items]") , 

            (1 - S_j)^(z_i #hide[k])
            G_j^((1-z_i))       & script("[Age-unrestricted items]") , 
          ) \
          k & = cases( 
            "logit"^(-1)( D("Age"_i - delta_j) ) #h(48pt) & script("[Type-1 & Type-2 items]"),
            "logit"^(-1)( D(delta_j - "Age"_i) )          & script("[Type-3 & Type-4 items]"),
          ) \
          z_i      & ~ "Bernoulli"(pi)
$ <model-spec>

#h(1.2em) Finally, the priors are specified in @priors. Two points are worth noting. First, $gamma_j$ is constrained#footnote[Through a scale transformation, $gamma'_j ~ "Beta"(2,2)$, where $gamma_j = 1/2 gamma'_j$.] to be bounded between $0$ and $0.5$ in order to consistently differentiate Type-1/3 items from Type-2/4 items, enabling model identification during fitting. Second, the mean and standard deviation for the normal prior of the delta parameter are set so that roughly 95% of the prior density encompasses the full age range of the data.

$
  S_j, G_j, & ~ "Beta"(2,2) \
  2 gamma_j & ~ "Beta"(2,2) #h(8pt) script("[" 0 lt.eq gamma_j lt.eq 0.5 "]")\
  pi                      & ~ "Beta(2,2)"    \
  delta_j                 & ~ "Normal"(  1/2 #h(2pt) underset("max", i) #h(2pt) "Age"_i, 1/4 #h(2pt) underset("max",i) #h(2pt) "Age"_i) \
  D                       & ~ "Exponential"(1)
$
<priors>


== Connections to the DINA model
Our model can be viewed as a modification of a two-attribute non-compensatory diagnostic classification model @rupp2010. Specifically, it largely resembles the deterministic inputs, noisy "and" gate model (a.k.a. the DINA model) @haertel1989 @junker2001 in structure, where $z_i$ and $k$ are the two attributes. The difference is that, in our model, $k$ is not a _static_ attribute tied to a person but a joint function of both the person's age and the item's age threshold. The interaction between the two attributes also differs between the models, as reflected in the exponents of the $G_j$ parameters below.

#set math.equation(numbering: none)
$
  up(P)(up(Y)_(i,j) = 1 | z_i, k_i, S_j, G_j)        & = (1 - S_j)^(z_i k_i) G_j^(1 - (z_i k_i))  & script("[DINA Model]") \
  up(P)(up(Y)_(i,j) = 1 | z_i, k, S_j, G_j, gamma_j) & = (1 - S_j)^(z_i k) G_j^((1-z_i)k) (...)   & script("[Our Model]")  
$
<compare>

== Modifications to meet practical demands <sec-practical-demands>
We used several synthetic datasets to test the model's ability to recover the parameters of the data-generating process. Initial attempts revealed that the item parameters were recovered with poor precision when fitting the model specified in @model-spec. The latent condition parameters $z_i$, on the other hand, were still correctly inferred, despite the high posterior variances in the item parameters.

As one of the primary goals of our model is to obtain precise item age threshold estimates for assessing item quality (i.e., to check whether these age estimates align with the literature and, if not, identify potential causes), we slightly modify the model to reduce the posterior variation in item parameters. Specifically, in our Stan @carpenter2017 implementation of the model, the $z_i$'s are _partially observed_, such that $z_i$ is treated as _data_ when person $i$'s true condition is known and as a _latent discrete parameter_ to be inferred when the true condition is unknown. This approach allows for a train-test split in which all $z_i$'s are treated as data in the training phase, alleviating the burden of simultaneously estimating item and person parameters and consequently resulting in more precise recovery of the item parameters. This approach also aligns well with the applied scenario our model is ultimately targeting. Specifically, a trained model is _necessary_ in such a context, where it provides predictions based on individuals' responses without refitting the full Bayesian model each time new data arrive.

Another modification to @model-spec is that we fix the prevalence parameter $pi$ to $0.5$. This adjustment forces the model to rely solely on the information in the item responses, excluding any reliance on the latent conditions' base rates in the population when computing the posterior probabilities of the conditions. This decision reflects that the prevalence of hearing loss in the sample used to fit the model differs from that in the general population. Furthermore, since our questionnaire is intended as a checklist-like resource for concerned parents and practitioners, we do not have prior knowledge of hearing loss prevalence in such a context, nor do we plan to estimate it. Therefore, we believe it is reasonable for the model to disregard the base rates of the latent conditions.

= Parameter Recovery Study <parameter-recovery>
We now describe the parameter recovery study and discuss several prominent properties of our model that we have observed.

#figure(
  table(
    columns: 3,
    table.header(
      [Parameter/Variable #h(5pt)],
      [Simulated values #h(5pt)],
      [N]
    ),
    [Child age ($"Age"_i$)],     [Uniform(0, 36)],     [Train: 300 / Test: 300],
    [Hearing condition ($z_i$)], [0 or 1 (50% each)],  [Train: 300 / Test: 300],
    [Age threshold ($delta_j$)], [Fixed to 3, 9,   \ 
                                  9, 9, 9, 12, 12, \ 
                                  12, 15, 15, 15,  \ 
                                  24, 24, 30, 30, 36], [16],
    [Slip ($S_j$)],              [Uniform(.35, .9)],   [20],
    [Guess ($G_j$)],             [Uniform(.02, .4)],   [20],
    [$gamma_j$],                 [Uniform(0, .3)],     [20],
    stroke: (x, y) => if y == 0 or y == 6 {
      (bottom: 0.7pt + black)
    }
  ), 
  caption: [
    Parameter values used in the simulation.
    The sixteen \ age-restricted items are all set as Type-1 items.
  ], 
)
<sim-param>

== Simulation
Three hundred subjects were simulated for training the model, and another three hundred for testing. The age distributions of the subjects were generated from a uniform distribution ranging from zero to thirty-six months. Sixteen items with age thresholds covering a similar age range, along with four additional age-unrestricted items, were simulated. The simulation, summarized in @sim-param, was designed to closely match our planned data collection scenario. In the simulation, we assign all items with age restrictions as Type-1 items.

#figure(image("figs/recovery.svg", width: 103%),
  placement: bottom,
  caption: [
    Recovery of the item parameters from the simulated data in @sim-param. The horizontal axes show true values, and the vertical axes show corresponding posterior estimates. Red dots indicate the posterior means, and bars represent the central 95% posterior densities. True age thresholds are labeled#footnote[Those labeled with $-1$ indicate age-unrestricted items.] near the means in the plots for the gamma ($gamma_j$), Guess ($G_j$), and Slip ($S_j$) parameters. As shown in these plots, the posterior variances of the gamma parameters are _negatively_ associated with age thresholds, while those of the Guess and Slip parameters are _positively_ associated with age thresholds.
  ]
)
<recovery> 

== Parameter recovery <sec-parameter-recovery>
@recovery plots the recovery of the item parameters by comparing the true (i.e., simulated) parameter values (horizontal axis) with their corresponding posterior estimates (vertical axis). The dots indicate posterior means, and the bars represent the central 95% posterior densities. Among the four types of item parameters listed, the age threshold parameters (top-left subplot) are the most reliably recovered, with the posterior means aligning closely with the gray identity line. 

The remaining parameters are generally recoverable, though extremely wide posteriors are observed for some. Indeed, for the $gamma_j$, $G_j$, and $S_j$ parameters, the posterior variances correlate with the item age thresholds (labeled as numbers next to the dots in the subplots): larger variances appear for items with higher age thresholds in the "Guess" and "Slip" parameters, while lower age thresholds show greater variance in the $gamma_j$ parameter. This effect arises from all items in the current simulation being Type-1 items. When Type-1 items have higher age thresholds, the "Guess" and "Slip" parameters have less available information, as younger samples cannot be used for estimation by model design. Conversely, more samples are available for estimating the $gamma_j$ parameter when a Type-1 item has a high age threshold. The pattern would reverse if Type-3 items were used. This is illustrated in @recovery2, which depicts the same parameter recovery as in @recovery but with Type-3 items used in the simulation instead.

#figure(image("figs/recovery-type3.svg", width: 103%),
  placement: top,
  caption: [
    This figure shows the recovery of item parameters similar to that in @recovery, with the only difference being that all age-restricted items are set to Type-3 instead of Type-1. The pattern of associations between posterior variances and age thresholds is now reversed.
  ]
)
<recovery2> 


== Predictions on hearing conditions
After training the model, it is applied to the testing dataset to infer the subjects' hearing conditions. In this prediction phase, the item parameters are kept fixed at the values estimated during the training phase. The individuals' hearing conditions ($z_i$) are now _unobserved_ latent discrete parameters to be inferred, as discussed in @sec-practical-demands. 

@prediction depicts the inference of hearing conditions on the testing dataset. The horizontal axes in the plots indicate the true hearing conditions assigned in the simulation, and the vertical axes represent the mean of the posterior hearing loss probability, $up(P)(z_i = 1|cal(D), cal(M))$, obtained from the model. To evaluate how well the hearing conditions are inferred, we set a mean posterior probability of $0.5$ as the criterion for assigning individuals to a prediction of either hearing loss or typical hearing. This enables us to calculate the model's sensitivity and specificity, where sensitivity is defined as the probability of a positive test case given an individual with hearing loss, $up(P)(+|"HL")$, and specificity is defined as the probability of a negative test case given an individual with typical hearing, $up(P)(-|"TH")$. These are shown in the panels in @prediction, where the three panels differ only in terms of the populations plotted: the left panel includes all subjects from the data, the central panel includes only subjects under 12 months old, and the right panel includes only those over 24 months old.

As can be seen from the plots in @prediction, higher accuracies (in terms of both sensitivity and specificity) are observed for older subjects. This phenomenon follows naturally from the fact that the prediction of an older subject's hearing condition is based on information from more items compared to younger individuals. Similar to the discussion in @sec-parameter-recovery, if Type-3 items had been used instead in the simulation, we would expect a reversed pattern, with higher accuracies observed for _younger_ subjects.

#figure(image("figs/predict.svg", width: 103%),
  placement: bottom,
  caption: [
    Predictions of subjects' hearing conditions in the testing dataset. The three panels each plots the predictions (based on the posterior probability of hearing loss) and their accuracies (sensitivity and specificity) for a subpopulation of the data (left: all subjects; center: subjects under 12 months old; right: subjects over 24 months old). The horizontal gray lines indicate a mean posterior probability of hearing loss of $0.5$, which is the criterion set for assigning predicted labels.
  ]
)
<prediction> 

#pagebreak()

= Implications for Scale Development <scale-development>
To utilize our model effectively in real-world applications, several subtleties need to be addressed. First, item construction requires careful attention. A review of items in published questionnaires and milestone checklists (e.g., #cite(<wachtlin2017>, form: "prose")) revealed that age-restricted items do not always correspond to any of the four item types in @age-pattern. We found that items developed for young children often target behaviors that exist only within specific developmental stages (e.g., babbling). Such items are not properly handled by our model and therefore cannot be included in the scale as is. A workaround is to modify these items by incorporating an "or" statement to remove the upper or lower boundary of the developmental stage. For instance, the item "Makes a lot of different sounds like 'mamamama' and 'bababababa'"#footnote(link("https://www.cdc.gov/ncbddd/actearly/milestones/milestones-9mo.html")) could be appended with "_or_ produces complete words" to create a Type-1 item. It is the authors' responsibility to ensure that items modified in this way are supported by the literature and backed by the empirical data collected.

Item selection also warrants careful consideration. Since parameter recovery depends on item type and age threshold (see @sec-parameter-recovery), it is crucial to avoid constructing a scale by selecting items without considering how their discriminative power functions with age. Doing so is likely to result in inefficient (or even complete failure of) parameter estimation. Importantly, when an item's age threshold is close to the maximum or minimum age in the data, trade-offs arise in how precisely the error rate parameters ($S_j$ and $G_j$) and the $gamma_j$ parameters can be recovered. One solution is to recruit participants with a broader age range than the expected range of all items' age thresholds. However, this may not always be feasible, particularly when the population of interest is very young children, making it impossible to cover ages below zero. In such cases, items expected to have an age threshold near zero might better be avoided. 

Alternatively, strategically concentrating participants within specific age ranges can be effective. For instance, recruiting more participants with children under 3 months old could work in principle, but there are additional trade-offs to consider. Concentrating participants can improve parameter estimation for certain items but may worsen the estimation for other items with very different age thresholds. For example, if participants are concentrated to enhance estimates for items with a low age threshold, fewer participants remain available to estimate the error rate parameters for items with a higher age threshold, assuming all items are Type-1. That being said, when a scale includes multiple item types, such as a mix of Type-1 and Type-3 items, concentrating participants within particular age ranges might be advantageous. Therefore, whether to concentrate, and which age range(s) to target, depends on the collective properties of the items involved. Simulations and parameter recovery studies are essential for addressing these complexities and provide a general approach to exploring the implications of various plausible item parameter patterns.

Finally, we highlight an unavoidable property of our model that becomes apparent in hindsight. Compared to a model with items that do not depend on age, our model requires a larger sample size to achieve the same level of precision. This is because the age restrictions on the items' discriminative power always result in fewer available samples for estimating item parameters than in the unrestricted case. Consequently, one should compensate for this limitation by maximizing sample-use efficiency through carefully considering the potential interactions among item types, age thresholds, and participants' age distribution. The exact effects of these interactions are case-specific and can only be reliably assessed through simulations and recovery studies. Therefore, model-based analysis should not only inform but also be integrated into conventional scale development practices to effectively address the additional challenges posed by items with age thresholds.

#bibliography("sty/ref.bib")
