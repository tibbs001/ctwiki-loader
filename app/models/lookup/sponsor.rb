module Lookup
  class Sponsor < SuperLookup
    self.table_name = 'lookup.sponsors'

    def self.impossible_descriptions
      super + [
        'scientific article',
        'athlete',
        'family name',
        'river in sweden',
        'tribe of plants',
        'television series',
        'scientific journal',
        'journalist',
        'chemical compound',
      ]
    end

    def self.possible_descriptions
      [
       'pharmaceutical corporation',
       'medical research organization',
       'company',
       'academic institution',
       'university',
       'medical research',
       'hospital'
      ]
    end

    def self.predefined_qcode
      # Most common sponsors - ordered list.
      {
        'US Department of Housing and Urban Development' => 'Q811595',
        'Scott Pruitt'                             =>  'Q168751',   # Scott is faculty at Duke University
        'SI-BONE, Inc.'                            => 'Q2878400',   # added this entity
        'National Cancer Institute (NCI)'          => 'Q664846',
        'GlaxoSmithKline'                          => 'Q212322',
        'Pfizer'                                   => 'Q206921',
        'Merck Sharp & Dohme Corp.'                => 'Q58219685',
        'AstraZeneca'                              => 'Q731938',
        'National Heart, Lung, and Blood Institute (NHLBI)' => 'Q6973027',
        'National Institute of Allergy and Infectious Diseases (NIAID)' => 'Q3519875',
        'Novartis Pharmaceuticals'                 => 'Q507154',
        'M.D. Anderson Cancer Center'              => 'Q1525831',
        'Hoffmann-La Roche'                        => 'Q212646',
        'Massachusetts General Hospital'           => 'Q126412',
        'Boehringer Ingelheim'                     => 'Q699532',
        'Mayo Clinic'                              => 'Q1130172',
        'Eli Lilly and Company'                    => 'Q632240',
        'Bristol-Myers Squibb'                     => 'Q266423',
        'National Institute of Mental Health (NIMH)' => 'Q1967405',
        'National Institutes of Health (NIH)'      => 'Q390551',
        'Bayer'                                    => 'Q152051',
        'Sanofi'                                   => 'Q158205',
        'National Institute on Drug Abuse (NIDA)'  => 'Q6973751',
        'University of California, San Francisco'  => 'Q1061104',
        'Assistance Publique - Hôpitaux de Paris'  => 'Q2867205',
        'National Institute of Diabetes and Digestive and Kidney Diseases (NIDDK)' => 'Q29220409',
        'Duke University'                          => 'Q168751',
        'National Taiwan University Hospital'      => 'Q1418766',
        'Memorial Sloan Kettering Cancer Center'   => 'Q1808012',
        'Novartis'                                 => 'Q507154',
        'Stanford University'                      => 'Q41506',
        'Johns Hopkins University'                 => 'Q193727',
        'Eunice Kennedy Shriver National Institute of Child Health and Human Development (NICHD)' => 'Q5409765',
        'University of Bedfordshire'               => 'Q8882735',
        'University of Pittsburgh'                 => 'Q235034',
        'Genentech, Inc.'                          => 'Q899140',
        'University of Pennsylvania'               => 'Q49117',
        'Washington University School of Medicine' => 'Q7972509',
      }
    end

    def self.names_to_ignore
      [
        'arctec',
        'anand prasad',
        'christian kern',
        'carol johnston',
        'salvador gil-vernet',
        'alisa apreleva',
        'victoria gomez',
        'yijing he',
        'rachel little',
        'balamurali ambati',
        'vincent kan',
        'joel lavine',
        'arctic',
        'nancy bauman',
        'lfce',
        'margarida vieira',
        'chen yajun',
        'jason bryant',
        'myocor',
        'back to life'                  ,  # 'collaborator defined for study NCT03616639  Ignore'
        'careggi hospital',
        'chen-yu chen',
        'christian nickel'              ,  # 'Q26272221 actor
        'gammacan',
        'irenbe',
        'tony eissa'                    ,  # 'Q22688616 actor
        'sunil rao'                     ,  # 'Q7640340 actor
        'stephens & associates, inc.',
        'tracie collins, MD, MPH'       ,  # 'Q23932108 actor
        'joseph hazelton'               ,  # 'Q6283869 American actor
        'michael rosenbaum'             ,  # 'Q311613 American actor
        'michelle lopez',
        'jeffrey kramer, MD'            ,  # 'Q6176107 American actor and producer
        'julian pine',
        'julie wang',
        'marc breton'                   ,  # 'Q3287847 French actor
        'andreas guenther'              ,  # 'Q497666 German actor
        'abdulkadir tunc'               ,  # 'Q15043411 Turkish actor
        'campbell grant'                ,  # 'Q2935481 US-American animator and dubbi
        'linda carlson'                 ,  # 'Q11832719 actress
        'lisa brenner'                  ,  # 'Q461378 American actress
        'chloe scott'                   ,  # 'Q47067499 American pornographic actress
        'fengxi su',
        'kaitlyn kelly, MD'             ,  # 'Q437226 American pornographic actress
        'kirsten williams'              ,  # 'Q6416126 Canadian actress
        'ditte hansen'                  ,  # 'Q12308738 Danish actress
        'mindframe, inc.'               ,  # 'Q42607297 movie theater in Dubuque, Iowa
        'david minor, MD'               ,  # 'Q43199624 movie theater in Eugene, Orego
        'envida, maastricht, the netherlands'       ,  # 'Q24250852 (1806-1859) soldier and public
        'sally falk'                    ,  # 'Q7405128 American anthropologist
        'holger thiele'                 ,  # 'Q562164 American astronomer
        'oscar goodman, jr.'            ,  # 'Q515259 American attorney and politici
        'bill mcghee'                   ,  # 'Q4910107 American baseball player
        'jerry zimmerman'               ,  # 'Q6184702 American baseball players
        'justin watts'                  ,  # 'Q16233655 American basketball player
        'lindsey miller'                ,  # 'Q6552896 American judge
        'grant jones'                   ,  # 'Q5596289 American landscape architect
        'james baumgartner, MD'         ,  # 'Q6133274 American logician
        'benjamin movsas, M.D.'         ,  # 'Q4889047 American physician
        'ronald hoffman'                ,  # 'Q7364939 American physician
        'paul carlson'                  ,  # 'Q15491063 American physician
        'kathryn stephenson'            ,  # 'Q6377129 American physician
        'stephen trokel'                ,  # 'Q1599537 American physicist
        'chen xiangmei'                 ,  # 'Q545822 American politician
        'andrew brenner'                ,  # 'Q4756413 American politician
        'caroline nilsson'              ,  # 'Q18685243 American politician
        'chloe scott'                   ,  # 'Q47067499 American pornographic actress
        'kaitlyn kelly, MD'             ,  # 'Q437226 American pornographic actress
        'natalie allen'                 ,  # 'Q17438529 American presenter, anchor and
        'mary fristad'                  ,  # 'Q45882355 American psychologist and acad
        'stefan g. hofmann'             ,  # 'Q37837264 American Psychology professor
        'kelly tanner'                  ,  # 'Q16194830 American stock car racing driv
        'adam friedman'                 ,  # 'Q2823944 American television producer a
        'obstetrix',
        'sharon walsh'                  ,  # 'Q461080 American tennis player
        'tularik',
        'joseph dib',
        'syral',
        'samantha harrison',
        'hongwen xu',
        'jeffrey browning'              ,  # 'Q16208757 American ultramarathon runner
        'jonathan berman',
        'euraxi',
        'tobias werther',
        'koyce fox'                     ,  # 'Q6297486 American writer
        'brenda cooper, md'             ,  # 'Q4960658 American writer
        'michael j. rosen, md.'         ,  # 'Q6831494 American writer
        'natasha duke'                  ,  # 'Q28802903 animator
        'airfan'                        ,  # 'Q55760547 association football player
        'chikara tashiro'               ,  # 'Q11576125 association football player
        'donnenfeld, eric, m.d.'        ,  # 'Q694508 Association footballer
        'florian beigel'                ,  # 'Q19661459 architect based in London
        'maria sklodowska-curie institute - oncology center'       ,  # 'Q1054401 architectural structure
        'asklepios klinik altona'       ,  # 'Q732015 architectural structure
        'Mary Knudson, M.D.'            ,  # 'Q58051223 anthropologist
        'SA Ambulance Service'          ,  # 'Q7388884 Australian ambulance service
        'Byron Lam'                     ,  # 'Q5004408 Australian botanist
        'Brian Walters'                 ,  # 'Q4965569 Australian politician
        'Brendan Lee'                   ,  # 'Q4960963 Australian rules footballer
        'David Birnie'                  ,  # 'Q377241 Australian serial killer
        'Lucy Holmes, MD'               ,  # 'Q6698364 Australian singer
        'Jacob Rosenberg'               ,  # 'Q6119196 Australian writer
        'Oliver Strohm'                 ,  # 'Q686257 Austrian ski jumper
        'Shashi Bhatt, MD'              ,  # 'Q13487172 badminton player
        'Johannes Wacker, MD'           ,  # 'Q27906334 badminton player
        'BaroNova, Inc.'                ,  # 'Q2467415 ballerina
        'Colaris, Joost, M.D.'          ,  # 'Q1107605 band
        'David A. Johnson, MD'          ,  # 'Q1038597 baseball player
        'Cengiz KAYA'                   ,  # 'Q6037195 basketball player
        'Brigade de Sapeurs Pompiers de Paris'       ,  # 'Q583422 brigade
        'Kenneth Hargreaves'            ,  # 'Q6390187 British Army officer
        'Michael Levy'                  ,  # 'Q337010 British Baron
        'Julie Page'                    ,  # 'Q1639835 British basketball player
        'Christopher Sweeney, MBBS'     ,  # 'Q17306850 British Director
        'Caroline Rowland'              ,  # 'Q5045208 British film producer
        'Krystal Parker'                ,  # 'Q6439758 British footballer
        'Nicholas Kenyon'               ,  # 'Q7025709 British journalist
        'Michael Gallagher'             ,  # 'Q6830494 British miner, politician and
        'Kevin Davy'                    ,  # 'Q6396118 British musician
        'Henry C. Lin, MD'              ,  # 'Q21453388 British painter (1877-1965)
        'Jenny Tong, MD, MPH'           ,  # 'Q334348 British politician
        'Joseph Bliss'                  ,  # 'Q6281570 British politician
        'ARGOS'                         ,  # 'Q4789707 British retail company
        'Alison Walker'                 ,  # 'Q4727205 British sports broadcaster
        'Jennifer Gay'                  ,  # 'Q6178342 British television announcer
        'George Brewer'                 ,  # 'Q5537230 British writer
        'NaiLab, Kenya'                 ,  # 'Q6959471 Businessperson
        'ovo r & d',
        'vesalio',
      ]
    end
  end
end
