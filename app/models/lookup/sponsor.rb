module Lookup
  class Sponsor < SuperLookup
    self.table_name = 'lookup.sponsors'

    def self.impossible_descriptions
      [
        'scientific article',
        'athlete',
        'family name',

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
        'University of Pittsburgh'                 => 'Q235034',
        'Genentech, Inc.'                          => 'Q899140',
        'University of Pennsylvania'               => 'Q49117',
        'Washington University School of Medicine' => 'Q7972509',
      }
    end

    def self.names_to_ignore
      [
        'back to life'                  ,  # 'collaborator defined for study NCT03616639  Ignore'
        'christian nickel'              ,  # 'Q26272221 actor
        'tony eissa'                    ,  # 'Q22688616 actor
        'Sunil Rao'                     ,  # 'Q7640340 actor
        'Tracie Collins, MD, MPH'       ,  # 'Q23932108 actor
        'Joseph Hazelton'               ,  # 'Q6283869 American actor
        'Michael Rosenbaum'             ,  # 'Q311613 American actor
        'Jeffrey Kramer, MD'            ,  # 'Q6176107 American actor and producer
        'Marc Breton'                   ,  # 'Q3287847 French actor
        'Andreas Guenther'              ,  # 'Q497666 German actor
        'Abdulkadir Tunc'               ,  # 'Q15043411 Turkish actor
        'Campbell Grant'                ,  # 'Q2935481 US-American animator and dubbi
        'Linda Carlson'                 ,  # 'Q11832719 actress
        'Lisa Brenner'                  ,  # 'Q461378 American actress
        'Chloe Scott'                   ,  # 'Q47067499 American pornographic actress
        'Kaitlyn Kelly, MD'             ,  # 'Q437226 American pornographic actress
        'Kirsten Williams'              ,  # 'Q6416126 Canadian actress
        'Ditte Hansen'                  ,  # 'Q12308738 Danish actress
        'MindFrame, Inc.'               ,  # 'Q42607297 movie theater in Dubuque, Iowa
        'David Minor, MD'               ,  # 'Q43199624 movie theater in Eugene, Orego
        'Envida, Maastricht, The Netherlands'       ,  # 'Q24250852 (1806-1859) soldier and public
        'Sally Falk'                    ,  # 'Q7405128 American anthropologist
        'Holger Thiele'                 ,  # 'Q562164 American astronomer
        'Oscar Goodman, Jr.'            ,  # 'Q515259 American attorney and politici
        'Bill McGhee'                   ,  # 'Q4910107 American baseball player
        'Jerry Zimmerman'               ,  # 'Q6184702 American baseball players
        'Justin Watts'                  ,  # 'Q16233655 American basketball player
        'Lindsey Miller'                ,  # 'Q6552896 American judge
        'Grant Jones'                   ,  # 'Q5596289 American landscape architect
        'James Baumgartner, MD'         ,  # 'Q6133274 American logician
        'Benjamin Movsas, M.D.'         ,  # 'Q4889047 American physician
        'Ronald Hoffman'                ,  # 'Q7364939 American physician
        'Paul Carlson'                  ,  # 'Q15491063 American physician
        'Kathryn Stephenson'            ,  # 'Q6377129 American physician
        'Stephen Trokel'                ,  # 'Q1599537 American physicist
        'Chen Xiangmei'                 ,  # 'Q545822 American politician
        'Andrew Brenner'                ,  # 'Q4756413 American politician
        'Caroline Nilsson'              ,  # 'Q18685243 American politician
        'Chloe Scott'                   ,  # 'Q47067499 American pornographic actress
        'Kaitlyn Kelly, MD'             ,  # 'Q437226 American pornographic actress
        'Natalie Allen'                 ,  # 'Q17438529 American presenter, anchor and
        'Mary Fristad'                  ,  # 'Q45882355 American psychologist and acad
        'Stefan G. Hofmann'             ,  # 'Q37837264 American Psychology professor
        'Kelly Tanner'                  ,  # 'Q16194830 American stock car racing driv
        'Adam Friedman'                 ,  # 'Q2823944 American television producer a
        'Sharon Walsh'                  ,  # 'Q461080 American tennis player
        'Jeffrey Browning'              ,  # 'Q16208757 American ultramarathon runner
        'Joyce Fox'                     ,  # 'Q6297486 American writer
        'Brenda Cooper, MD'             ,  # 'Q4960658 American writer
        'Michael J. Rosen, MD.'         ,  # 'Q6831494 American writer
        'Natasha Duke'                  ,  # 'Q28802903 animator
        'AIRFAN'                        ,  # 'Q55760547 association football player
        'Chikara Tashiro'               ,  # 'Q11576125 association football player
        'Donnenfeld, Eric, M.D.'        ,  # 'Q694508 Association footballer
        'Florian Beigel'                ,  # 'Q19661459 architect based in London
        'Maria Sklodowska-Curie Institute - Oncology Center'       ,  # 'Q1054401 architectural structure
        'Asklepios Klinik Altona'       ,  # 'Q732015 architectural structure
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
      ]
    end
  end
end
