# Why the app looks and works the way it does

Every design decision, the finding behind it, and the source. Claims are kept as strong as the
evidence and no stronger; limits are named. Token values live in `design/SYSTEM.md`, the words
of every wheel in `design/WORDS.md`.

## The person we design for

Someone opening an emotion wheel is often upset, tired or unsure what they feel. Acute stress
narrows working memory and flexible thinking (Arnsten 2009; Shields, Sazma & Yonelinas 2016).
So the main path must ask for very little: no reading, few choices, big targets.

## Decisions

| Decision | Why | Sources |
|---|---|---|
| The wheel is on screen in the first frame; no onboarding, account, streaks or notifications | Stress shrinks working memory; most people leave mental-health apps within days (median 15-day retention 3.9%); streak pressure, self-tracking and alerts can cost wellbeing; design should support autonomy | Arnsten 2009; Shields et al. 2016; Baumel et al. 2019; Etkin 2016; Silverman & Barasch 2023; Kushlev, Proulx & Dunn 2016; Peters, Calvo & Ryan 2018 |
| The wheel is for looking: nothing to tap or choose, only pinch and move | Owner's choice (2026-11-15): finding the word is the point; naming it happens in your head, not in the app. Fewer controls, less clutter | Nielsen 2006; Rosenholtz, Li & Nakano 2007 |
| Every word is drawn at every zoom, in capitals, even when small; pinch to read | Owner's choice (2026-11-15): hidden words hid the fact that you can zoom. Trade-off we accept knowingly: rotated text is read about 81% slower than horizontal, and the smallest words need a pinch | Yu, Park, Gerold & Legge 2010 |
| Every outermost word gets the same slice of the circle; each family is as wide as its words; the middle and outer words share one size; ring widths are fitted to each screen | Owner's choice (2026-11-19): some families were squeezed while others had half-empty slices. Equal slices are also how the Lithuanian picture is drawn. The ring split is searched per screen so the words come out as large as the space allows (on a 402 dp phone about 6.1 dp with thin lines between words; see the rows below for the trade-offs) | Pokalbių gidas wheel; `lib/wheel/sunburst_layout.dart` |
| Family names run along the radius too (no longer curved) | With equal slices Nuostaba and Pasibjaurėjimas get only 35°, where a curved name cannot fit at a readable size; along the radius they do. Same trade-off as above: rotated text reads slower | Yu et al. 2010 |
| Family names are never broken in two: one size for all, each in the middle of its slice | Owner's choice (2026-11-20): "PASIBJAU-RĖJIMAS" on two lines was hard to read at a glance; a whole word, a little smaller, reads at once. The size is set so the longest name fits whole halfway along its slice, the way the Lithuanian picture draws it. Cost, accepted knowingly: on a 402 dp phone family names went from about 8.4 to 7.0 dp and the other words from 6.6 to 5.9 dp (7.3 and 6.1 once the gaps became thin lines). Names stay about 1.2× larger and heavier than the other words | Pokalbių gidas wheel; `lib/wheel/sunburst_layout.dart` |
| Every word of a family reads the same way along the radius | Owner's choice (2026-11-20): "Ilgesys" read the other way from the rest of Meilė. A family's middle decides: outward on the right half, inward on the left, top to bottom at 12 or 6 o'clock. Words just across 12 or 6 o'clock lean at most about 24° past upright | Yu et al. 2010 |
| Wheel words heavy (ExtraBold, family names Black) | Owner's choice (2026-11-19). Bolder strokes help small text at the edge of legibility, but only a little (about 1–10%) | Sheedy, Subbaram, Zimmerman & Hayes 2005 |
| Plutchik's innermost (intense) words run along the radius | The centre slices are too narrow for level words (they were about 4 dp); along the radius they are about twice as large. Basic and mild words stay level | Yu et al. 2010 |
| No word on Plutchik's flower is broken in two; one size per band; the mixtures never larger than the basic feelings | Same owner's choice as the family names (2026-11-20). The bands were re-proportioned so the longest words fit whole: on a 402 dp phone about 7.5 dp for intense and basic words (basic was 9.8 with "PASITI-KĖJIMAS" and "PASIBJAU-RĖJIMAS" broken) and 6.8 for mild ones. "Nuogąstavimas" at 3 o'clock runs a little past its petal tip | `lib/wheel/petal_layout.dart` |
| A wheel at all, and more than one word may fit | Recognising a word is easier than recalling it; mixed feelings are real | Budiu 2014 (NN/g); Larsen & McGraw 2011; Berrios, Totterdell & Kellett 2015 |
| Buttons at the bottom right, in one small cluster: the flower in the corner, "?" just left of it, "Atstatyti" above the flower while zoomed in; touch targets ≥ 48 dp, 8 dp apart | The bottom right is inside a right thumb's reach when the phone is held in one hand; one-handed thumb accuracy needs about 9.2–9.6 mm | Bergstrom-Lehtovirta & Oulasvirta 2014; Parhi, Karlson & Bederson 2006; Android accessibility guidance; WCAG 2.2 SC 2.5.8 / 2.5.5 |
| The question and hint step aside while the wheel is zoomed in, and come back with the whole wheel | Owner's choice (2026-11-19): the zoomed wheel gets the full height. Guidance at the edge of attention, there when needed | Weiser & Brown 1997 |
| The hint under the question shows on the first opening and then on every third | Owner's choice (2026-11-20): read every time, the same hint becomes words the eye learns to skip; now and then it stays a quiet reminder. Openings are counted on the phone only | Weiser & Brown 1997 |
| Muted, light feeling tints; colour reserved for feelings, interface in ink and paper | Saturation raises arousal (both studies agree); light colours go with positive feelings; colour variety adds clutter. We do not claim colour makes anyone calm | Valdez & Mehrabian 1994; Wilms & Oberfeld 2018; Jonauskaite & Mohr 2025; Rosenholtz et al. 2007; Elliot & Maier 2014 |
| Hues follow common associations (anger red, joy yellow, sadness blue) and each author's own scheme | Colour–emotion associations are similar across 30 nations (tested with colour words) | Jonauskaite et al. 2020 |
| Rounded segments, petals, soft corners | Preference for curvature is reliable but not universal (g = 0.39) | Chuquichambi et al. 2022; Bertamini et al. 2016; Bar & Neta 2006 |
| On the two ring wheels, words are parted by thin lines instead of gaps, with corners only slightly rounded | Owner's choice (2026-11-20): the gaps and round "pills" took room from the words. With 0.75–1.5 dp lines the words come out about 4–6% larger, and the wheel looks like the Lithuanian picture it comes from. Trade-off: less of the soft, rounded look above. Plutchik's flower keeps its gaps, which shape the petals | Pokalbių gidas wheel; `lib/wheel/sunburst_layout.dart` |
| Light warm default; dark theme follows the system | Dark text on a light background reads better; evidence for dark mode at night is weak | Piepenbrock, Mayr, Mund & Buchner 2013 |
| Dark theme is a muted evening blue with dusk tints, not near-black; ink is a soft moonlight white | Owner's choice (2026-11-19): the near-black felt heavy. Blue and blue-green hues are rated most pleasant and low saturation is least arousing; the tints keep each family's hue at lower lightness and chroma. We do not claim the colour calms anyone | Valdez & Mehrabian 1994; Wilms & Oberfeld 2018 |
| Contrast ≥ 4.5:1 for every text pair and every label on every tint (unit-tested); slices gapped and labelled | Legibility; non-text contrast rule for chart slices | WCAG 2.1 SC 1.4.3, 1.4.11 |
| Reading page: 17 sp, line height 1.5, about 65 characters per line, sentence case | Readable line length and spacing; mixed case for running text | WCAG 2.1 SC 1.4.8; Dyson 2004; Arditi & Cho 2007 |
| "Kaip naudotis" holds only how to use the wheel, a tile to "Kodėl emocijų ratas gali būti naudingas?", and the help lines | Owner's choice (2026-11-20): a long page was hard to start, and help must never be folded away or pushed down. Everything else waits one tap behind the tile | Nielsen 2006 |
| "Kodėl emocijų ratas gali būti naudingas?" is a short tour: six numbered chapters, the first open, one open at a time, each ending in "Toliau"; then "Apie programėlę" and the sources | Owner's choice (2026-11-20). Folded chapters show a title and a first sentence, a taste that invites a touch; "Toliau" lets the page be read like a little book, and closing the last chapter leads back to the wheel. The title says "gali būti" because no trial has tested emotion wheels themselves (see below) | Nielsen 2006 |
| Motion short and eased, off when the system asks (Android and iOS flags both read) | Vestibular comfort | WCAG 2.1 SC 2.3.3; Apple HIG (Motion) |
| Visible buttons instead of a hidden menu; the wheel button is the app's flower, without words | Hiding navigation roughly halves discoverability, so nothing hides in a menu. Owner's choice (2026-11-19): the wheel button shows only the flower icon; its name "Keisti ratą" lives in the tooltip and for screen readers. Trade-off: an icon alone is easier to miss than a labelled button | Nielsen Norman Group 2016 |
| Nothing leaves the phone | 33 of 36 popular mental-health apps sent data to third parties; trust and privacy drive drop-out | Huckvale, Torous & Larsen 2019; Torous et al. 2018 |
| Calm, at the edge of attention | Calm technology | Weiser & Brown 1997 |
| An energy × pleasantness wheel for when no word comes | Core affect as a circumplex; the one-point Affect Grid | Russell 1980; Russell, Weiss & Mendelsohn 1989; Posner, Russell & Peterson 2005 |
| Help lines two taps away | Links to crisis support are a recommended feature | Bakker, Kazantzis, Rickwood & Rickard 2016 (recommendation 15) |
| One font everywhere: Nunito, a rounded sans | Owner's request for a more pleasant font (2026-11-19). Round letter shapes go with easier processing and more liking; people prefer curved shapes; one family keeps the page quiet. Font evidence is modest and the best font differs per person | Velasco, Woods, Hyndman & Spence 2015; Bar & Neta 2006; Wallace et al. 2022 |
| Lithuanian words only from existing Lithuanian wheels and lists | The owner's rule: translations can be subtly wrong; every word records its source | `design/WORDS.md`, `lib/data/sources.dart` |

## What the reading pages claim, and their limits

Checked on 2026-11-20 against each paper's record and abstract (Crossref, PubMed, OpenAlex):
every DOI resolves and none is retracted. The check changed the text: the amygdala is no
longer called a "danger centre"; Lieberman et al. 2007 labelled emotional faces, so the claim
speaks of "naming emotions", not one's own; the breathing step asks for slow breaths, since a
longer out-breath was not what the reviews tested; mild feelings are not pushed to be named
(it raised distress in one study); Shaver's sixth family is marked as less clear; mixed
feelings are "real", not "frequent"; the privacy line lists all four stored things; titles and
claims say "gali" where the evidence is a link, not a cause; "1 in 10" names its two
countries; one line with no source behind it ("žodis rankoje retai būna nereikalingas") is
gone. Seven reference titles were completed, one title and page range corrected (Bruno
2024) and one issue number added (Verduyn 2015).

- **Naming a strong unpleasant feeling can help it settle a little.** Less amygdala and limbic
  activity when emotions in pictures are put into words (Lieberman et al. 2007); lower skin
  conductance a week after spider exposure with labelling, though self-reported fear did not
  change (Kircanski, Lieberman & Craske 2012); review in Torre & Lieberman 2018, including that
  labelling may not feel like regulation. Limits: for mildly unpleasant pictures labelling raised
  distress (Levy-Gigi & Shamay-Tsoory 2022, n = 79); analysing one's happiest days in writing
  lowered well-being against replaying them (Lyubomirsky, Sousa & Dickerhoof 2006).
- **Finer feeling words go with better coping.** More regulation of intense negative feelings
  (Barrett et al. 2001); strategies work better, though they are not chosen differently
  (Kalokerinos et al. 2019); less binge drinking and aggression under distress (Kashdan, Barrett
  & McKnight 2015); r = −.15 across 17 studies, −.09 after negative affect (Seah & Coifman 2022);
  in teenagers, low differentiation let severe stress predict later depression (Starr et al.
  2020). Limit: correlational and small, and such measures add little beyond average mood
  (Dejonckheere et al. 2019).
- **It can be learned.** An emotion-knowledge lesson raised negative emotion differentiation in
  a randomised study, n = 120 (Vedernikova, Kuppens & Erbas 2021); word prompts did too, as
  preliminary evidence, with no change in symptoms (Seah & Coifman 2025, n = 92 students);
  check-ins several times a day raised granularity (Hoemann, Barrett & Quigley 2021;
  Widdershoven et al. 2019, in depression). About 1 in 10 adults score as alexithymic: 9.9% in
  Finland (Mattila et al. 2006), 10% in Germany (Franz et al. 2008).
- **No trial has tested emotion wheels themselves** (PubMed and ERIC searches found none; one
  small uncontrolled app study: Bruno et al. 2024, n = 16). The app therefore calls the wheel a
  word helper.
- **Mixed feelings are real**: happy and sad at once during a bittersweet film, not merely
  switching (Larsen & McGraw 2011); robust across 63 studies, d = 0.77 (Berrios, Totterdell &
  Kellett 2015).
- **Feelings pass**: of 27 emotions recalled by 233 secondary-school students, sadness lasted
  longest and surprise, fear and irritation were among the shortest; important events and
  rumination made feelings last (Verduyn & Lavrijsen 2015).
- Slow breathing (fewer than 10 breaths a minute) raises heart-rate variability and comes with
  more calm (Zaccaro et al. 2018; Laborde et al. 2022, 223 studies); body maps of feelings
  (Nummenmaa et al. 2014); writing it down (small effect, r = .075: Frattaroli 2006); and
  researchers' disagreement about "basic" emotions (Plutchik 2001; Barrett 2017; Lindquist,
  MacCormack & Shablack 2015). Shaver et al. (1987) found love, joy, anger, sadness, fear "and
  perhaps surprise".
- **Privacy**: transmission to third parties was found in 33 of 36 top apps for depression and
  smoking cessation (Huckvale, Torous & Larsen 2019). This app stores four things on the phone
  only: the last wheel, the word form, the colours and how many times it was opened.

## Not used, and why

- **Geneva Emotion Wheel**: commercial use requires a licence from the University of Geneva.
- **Atlas of Emotions** (Ekman): content reuse needs permission.
- **Yale Mood Meter**: its name, square four-colour grid and word list are not copied; the energy
  circle is drawn from Russell's own circular model with Lithuanian PANAS-X words.
- **Roberts' Feelings Wheel** (the basis of the Lithuanian main wheel) has no published licence:
  ask Geoffrey Roberts before a store release, and credit Pokalbių gidas for the Lithuanian
  wording.

## References

Arditi, A., & Cho, J. (2007). Letter case and text legibility in normal and low vision. *Vision Research, 47*(19), 2499–2505. https://doi.org/10.1016/j.visres.2007.06.010
Arnsten, A. F. T. (2009). Stress signalling pathways that impair prefrontal cortex structure and function. *Nature Reviews Neuroscience, 10*(6), 410–422. https://doi.org/10.1038/nrn2648
Bakker, D., Kazantzis, N., Rickwood, D., & Rickard, N. (2016). Mental health smartphone apps: Review and evidence-based recommendations. *JMIR Mental Health, 3*(1), e7. https://doi.org/10.2196/mental.4984
Bar, M., & Neta, M. (2006). Humans prefer curved visual objects. *Psychological Science, 17*(8), 645–648. https://doi.org/10.1111/j.1467-9280.2006.01759.x
Barrett, L. F. (2017). The theory of constructed emotion. *Social Cognitive and Affective Neuroscience, 12*(1), 1–23. https://doi.org/10.1093/scan/nsw154
Barrett, L. F., Gross, J., Christensen, T. C., & Benvenuto, M. (2001). Knowing what you're feeling and knowing what to do about it. *Cognition and Emotion, 15*(6), 713–724. https://doi.org/10.1080/02699930143000239
Baumel, A., Muench, F., Edan, S., & Kane, J. M. (2019). Objective user engagement with mental health apps. *Journal of Medical Internet Research, 21*(9), e14567. https://doi.org/10.2196/14567
Bergstrom-Lehtovirta, J., & Oulasvirta, A. (2014). Modeling the functional area of the thumb on mobile touchscreen surfaces. *CHI '14*, 1991–2000. https://doi.org/10.1145/2556288.2557354
Berrios, R., Totterdell, P., & Kellett, S. (2015). Eliciting mixed emotions: A meta-analysis. *Frontiers in Psychology, 6*, 428. https://doi.org/10.3389/fpsyg.2015.00428
Bertamini, M., Palumbo, L., Gheorghes, T. N., & Galatsidas, M. (2016). Do observers like curvature or do they dislike angularity? *British Journal of Psychology, 107*(1), 154–178. https://doi.org/10.1111/bjop.12132
Bruno, L., Iborra Cuéllar, A., Pasikowski, S., & Lindquist, K. A. (2024). EMOTONGUE. *Pulso, 47*, 97–125. https://doi.org/10.58265/pulso.6633
Budiu, R. (2014). Memory recognition and recall in user interfaces. Nielsen Norman Group. https://www.nngroup.com/articles/recognition-and-recall/
Chuquichambi, E. G., et al. (2022). How universal is preference for visual curvature? *Annals of the New York Academy of Sciences, 1518*(1), 151–165. https://doi.org/10.1111/nyas.14919
Cockburn, A., Gutwin, C., & Greenberg, S. (2007). A predictive model of menu performance. *CHI '07*. https://doi.org/10.1145/1240624.1240723
Dejonckheere, E., et al. (2019). Complex affect dynamics add limited information to the prediction of psychological well-being. *Nature Human Behaviour, 3*(5), 478–491. https://doi.org/10.1038/s41562-019-0555-0
Dyson, M. C. (2004). How physical text layout affects reading from screen. *Behaviour & Information Technology, 23*(6), 377–393. https://doi.org/10.1080/01449290410001715714
Elliot, A. J., & Maier, M. A. (2014). Color psychology. *Annual Review of Psychology, 65*, 95–120. https://doi.org/10.1146/annurev-psych-010213-115035
Etkin, J. (2016). The hidden cost of personal quantification. *Journal of Consumer Research, 42*(6), 967–984. https://doi.org/10.1093/jcr/ucv095
Franz, M., et al. (2008). Alexithymia in the German general population. *Social Psychiatry and Psychiatric Epidemiology, 43*(1), 54–62. https://doi.org/10.1007/s00127-007-0265-1
Frattaroli, J. (2006). Experimental disclosure and its moderators: A meta-analysis. *Psychological Bulletin, 132*(6), 823–865. https://doi.org/10.1037/0033-2909.132.6.823
Hoemann, K., Barrett, L. F., & Quigley, K. S. (2021). Emotional granularity increases with intensive ambulatory assessment. *Frontiers in Psychology, 12*, 704125. https://doi.org/10.3389/fpsyg.2021.704125
Huckvale, K., Torous, J., & Larsen, M. E. (2019). Data sharing and privacy practices of apps for depression and smoking cessation. *JAMA Network Open, 2*(4), e192542. https://doi.org/10.1001/jamanetworkopen.2019.2542
Jonauskaite, D., et al. (2020). Universal patterns in color-emotion associations. *Psychological Science, 31*(10), 1245–1260. https://doi.org/10.1177/0956797620948810
Jonauskaite, D., & Mohr, C. (2025). Do we feel colours? *Psychonomic Bulletin & Review, 32*(4), 1457–1486. https://doi.org/10.3758/s13423-024-02615-z
Kalokerinos, E. K., Erbas, Y., Ceulemans, E., & Kuppens, P. (2019). Differentiate to regulate. *Psychological Science, 30*(6), 863–879. https://doi.org/10.1177/0956797619838763
Kashdan, T. B., Barrett, L. F., & McKnight, P. E. (2015). Unpacking emotion differentiation. *Current Directions in Psychological Science, 24*(1), 10–16. https://doi.org/10.1177/0963721414550708
Kircanski, K., Lieberman, M. D., & Craske, M. G. (2012). Feelings into words. *Psychological Science, 23*(10), 1086–1091. https://doi.org/10.1177/0956797612443830
Kushlev, K., Proulx, J., & Dunn, E. W. (2016). "Silence your phones." *CHI '16*, 1011–1020. https://doi.org/10.1145/2858036.2858359
Laborde, S., et al. (2022). Effects of voluntary slow breathing on heart rate and heart rate variability. *Neuroscience & Biobehavioral Reviews, 138*, 104711. https://doi.org/10.1016/j.neubiorev.2022.104711
Larsen, J. T., & McGraw, A. P. (2011). Further evidence for mixed emotions. *Journal of Personality and Social Psychology, 100*(6), 1095–1110. https://doi.org/10.1037/a0021846
Levy-Gigi, E., & Shamay-Tsoory, S. (2022). Affect labeling: The role of timing and intensity. *PLoS ONE, 17*(12), e0279303. https://doi.org/10.1371/journal.pone.0279303
Lieberman, M. D., et al. (2007). Putting feelings into words. *Psychological Science, 18*(5), 421–428. https://doi.org/10.1111/j.1467-9280.2007.01916.x
Lindquist, K. A., MacCormack, J. K., & Shablack, H. (2015). The role of language in emotion. *Frontiers in Psychology, 6*, 444. https://doi.org/10.3389/fpsyg.2015.00444
Liu, W., et al. (2020). How relevant is Hick's law for HCI? *CHI '20*. https://doi.org/10.1145/3313831.3376878
Lyubomirsky, S., Sousa, L., & Dickerhoof, R. (2006). The costs and benefits of writing, talking, and thinking about life's triumphs and defeats. *JPSP, 90*(4), 692–708. https://doi.org/10.1037/0022-3514.90.4.692
Mattila, A. K., Salminen, J. K., Nummi, T., & Joukamaa, M. (2006). Age is strongly associated with alexithymia. *Journal of Psychosomatic Research, 61*(5), 629–635. https://doi.org/10.1016/j.jpsychores.2006.04.013
Nielsen, J. (2006). Progressive disclosure. Nielsen Norman Group. https://www.nngroup.com/articles/progressive-disclosure/
Nielsen Norman Group (2016). Hamburger menus and hidden navigation hurt UX metrics. https://www.nngroup.com/articles/hamburger-menus/
Nummenmaa, L., Glerean, E., Hari, R., & Hietanen, J. K. (2014). Bodily maps of emotions. *PNAS, 111*(2), 646–651. https://doi.org/10.1073/pnas.1321664111
Parhi, P., Karlson, A. K., & Bederson, B. B. (2006). Target size study for one-handed thumb use on small touchscreen devices. *MobileHCI '06*. https://doi.org/10.1145/1152215.1152260
Parrott, W. G. (Ed.). (2001). *Emotions in social psychology: Essential readings*. Psychology Press.
Peters, D., Calvo, R. A., & Ryan, R. M. (2018). Designing for motivation, engagement and wellbeing in digital experience. *Frontiers in Psychology, 9*, 797. https://doi.org/10.3389/fpsyg.2018.00797
Piepenbrock, C., Mayr, S., Mund, I., & Buchner, A. (2013). Positive display polarity is advantageous for both younger and older adults. *Ergonomics, 56*(7), 1116–1124. https://doi.org/10.1080/00140139.2013.790485
Plutchik, R. (1980). *Emotion: A psychoevolutionary synthesis*. Harper & Row.
Plutchik, R. (2001). The nature of emotions. *American Scientist, 89*(4), 344–350. https://doi.org/10.1511/2001.4.344
Posner, J., Russell, J. A., & Peterson, B. S. (2005). The circumplex model of affect. *Development and Psychopathology, 17*(3), 715–734. https://doi.org/10.1017/S0954579405050340
Rosenholtz, R., Li, Y., & Nakano, L. (2007). Measuring visual clutter. *Journal of Vision, 7*(2), 17. https://doi.org/10.1167/7.2.17
Russell, J. A. (1980). A circumplex model of affect. *JPSP, 39*(6), 1161–1178. https://doi.org/10.1037/h0077714
Russell, J. A., Weiss, A., & Mendelsohn, G. A. (1989). Affect Grid. *JPSP, 57*(3), 493–502. https://doi.org/10.1037/0022-3514.57.3.493
Seah, T. H. S., & Coifman, K. G. (2022). Emotion differentiation and behavioral dysregulation: A meta-analysis. *Emotion, 22*(7), 1686–1697. https://doi.org/10.1037/emo0000968
Seah, T. H. S., & Coifman, K. G. (2025). Effects of scaffolding emotion language use on emotion differentiation. *Cognition and Emotion, 39*(7), 1719–1736. https://doi.org/10.1080/02699931.2024.2382334
Shaver, P., Schwartz, J., Kirson, D., & O'Connor, C. (1987). Emotion knowledge. *JPSP, 52*(6), 1061–1086. https://doi.org/10.1037/0022-3514.52.6.1061
Sheedy, J. E., Subbaram, M. V., Zimmerman, A. B., & Hayes, J. R. (2005). Text legibility and the letter superiority effect. *Human Factors, 47*(4), 797–815. https://doi.org/10.1518/001872005775570998
Shields, G. S., Sazma, M. A., & Yonelinas, A. P. (2016). The effects of acute stress on core executive functions. *Neuroscience & Biobehavioral Reviews, 68*, 651–668. https://doi.org/10.1016/j.neubiorev.2016.06.038
Silverman, J., & Barasch, A. (2023). On or off track: How (broken) streaks affect consumer decisions. *Journal of Consumer Research, 49*(6), 1095–1117. https://doi.org/10.1093/jcr/ucac029
Starr, L. R., et al. (2020). The perils of murky emotions. *Emotion, 20*(6), 927–938. https://doi.org/10.1037/emo0000630
Torous, J., Nicholas, J., Larsen, M. E., Firth, J., & Christensen, H. (2018). Clinical review of user engagement with mental health smartphone apps. *Evidence-Based Mental Health, 21*(3), 116–119. https://doi.org/10.1136/eb-2018-102891
Torre, J. B., & Lieberman, M. D. (2018). Putting feelings into words. *Emotion Review, 10*(2), 116–124. https://doi.org/10.1177/1754073917742706
Valdez, P., & Mehrabian, A. (1994). Effects of color on emotions. *Journal of Experimental Psychology: General, 123*(4), 394–409. https://doi.org/10.1037/0096-3445.123.4.394
Velasco, C., Woods, A. T., Hyndman, S., & Spence, C. (2015). The taste of typeface. *i-Perception, 6*(4). https://doi.org/10.1177/2041669515593040
Vedernikova, E., Kuppens, P., & Erbas, Y. (2021). From knowledge to differentiation. *Frontiers in Psychology, 12*, 703757. https://doi.org/10.3389/fpsyg.2021.703757
Verduyn, P., & Lavrijsen, S. (2015). Which emotions last longest and why. *Motivation and Emotion, 39*, 119–127. https://doi.org/10.1007/s11031-014-9445-y
Wallace, S., et al. (2022). Towards individuated reading experiences. *ACM TOCHI, 29*(4). https://doi.org/10.1145/3502222
Weiser, M., & Brown, J. S. (1997). The coming age of calm technology. In *Beyond Calculation* (pp. 75–85). Springer. https://doi.org/10.1007/978-1-4612-0685-9_6
Widdershoven, R. L. A., et al. (2019). Effect of self-monitoring through experience sampling on emotion differentiation in depression. *Journal of Affective Disorders, 244*, 71–77. https://doi.org/10.1016/j.jad.2018.10.092
Wilms, L., & Oberfeld, D. (2018). Color and emotion: Effects of hue, saturation, and brightness. *Psychological Research, 82*(5), 896–914. https://doi.org/10.1007/s00426-017-0880-8
Yu, D., Park, H., Gerold, D., & Legge, G. E. (2010). Comparing reading speed for horizontal and vertical English text. *Journal of Vision, 10*(2), 21. https://doi.org/10.1167/10.2.21

Standards: WCAG 2.1/2.2 SC 1.3.4, 1.4.3, 1.4.8, 1.4.11, 2.3.3, 2.5.5, 2.5.8 (w3.org/WAI). Android
accessibility guidance (48 dp targets). Apple Human Interface Guidelines: Accessibility, Motion.
