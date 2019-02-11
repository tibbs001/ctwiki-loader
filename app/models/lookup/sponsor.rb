module Lookup
  class Sponsor < SuperLookup
    self.table_name = 'lookup.sponsors'

    def qcode
      Lookup::Sponsor.qcode_for(name)
    end

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
      [        'argos'                         ,  # 'q4789707 british retail company
        'baronova, inc.'                ,  # 'q2467415 ballerina
        'brendan lee'                   ,  # 'q4960963 australian rules footballer
        'brian walters'                 ,  # 'q4965569 australian politician
        'brigade de sapeurs pompiers de paris'       ,  # 'q583422 brigade
        'byron lam'                     ,  # 'q5004408 australian botanist
        'caroline rowland'              ,  # 'q5045208 british film producer
        'cengiz kaya'                   ,  # 'q6037195 basketball player
        'christopher sweeney, mbbs'     ,  # 'q17306850 british director
        'colaris, joost, m.d.'          ,  # 'q1107605 band
        'david a. johnson, md'          ,  # 'q1038597 baseball player
        'david birnie'                  ,  # 'q377241 australian serial killer
        'henry c. lin, md'              ,  # 'q21453388 british painter (1877-1965)
        'jacob rosenberg'               ,  # 'q6119196 australian writer
        'jenny tong, md, mph'           ,  # 'q334348 british politician
        'johannes wacker, md'           ,  # 'q27906334 badminton player
        'joseph bliss'                  ,  # 'q6281570 british politician
        'julie page'                    ,  # 'q1639835 british basketball player
        'kenneth hargreaves'            ,  # 'q6390187 british army officer
        'kevin davy'                    ,  # 'q6396118 british musician
        'krystal parker'                ,  # 'q6439758 british footballer
        'lucy holmes, md'               ,  # 'q6698364 australian singer
        'mary knudson, m.d.'            ,  # 'q58051223 anthropologist
        'michael gallagher'             ,  # 'q6830494 british miner, politician and
        'michael levy'                  ,  # 'q337010 british baron
        'nicholas kenyon'               ,  # 'q7025709 british journalist
        'oliver strohm'                 ,  # 'q686257 austrian ski jumper
        'sa ambulance service'          ,  # 'q7388884 australian ambulance service
        'shashi bhatt, md'              ,  # 'q13487172 badminton player
        'abdulkadir tunc'               ,  # 'q15043411 turkish actor
        'adam friedman'                 ,  # 'q2823944 american television producer a
        'airfan'                        ,  # 'q55760547 association football player
        'alisa apreleva',
        'alison walker'                 ,  # 'q4727205 british sports broadcaster
        'anand prasad',
        'andreas guenther'              ,  # 'q497666 german actor
        'andrew brenner'                ,  # 'q4756413 american politician
        'arctec',
        'arctic',
        'asklepios klinik altona'       ,  # 'q732015 architectural structure
        'back to life'                  ,  # 'collaborator defined for study nct03616639  ignore'
        'balamurali ambati',
        'benjamin movsas, m.d.'         ,  # 'q4889047 american physician
        'bill mcghee'                   ,  # 'q4910107 american baseball player
        'brenda cooper, md'             ,  # 'q4960658 american writer
        'campbell grant'                ,  # 'q2935481 us-american animator and dubbi
        'careggi hospital',
        'carol johnston',
        'caroline nilsson'              ,  # 'q18685243 american politician
        'chen xiangmei'                 ,  # 'q545822 american politician
        'chen yajun',
        'chen-yu chen',
        'chikara tashiro'               ,  # 'q11576125 association football player
        'chloe scott'                   ,  # 'q47067499 american pornographic actress
        'chloe scott'                   ,  # 'q47067499 american pornographic actress
        'christian kern',
        'christian nickel'              ,  # 'q26272221 actor
        'david minor, md'               ,  # 'q43199624 movie theater in eugene, orego
        'ditte hansen'                  ,  # 'q12308738 danish actress
        'donnenfeld, eric, m.d.'        ,  # 'q694508 association footballer
        'envida, maastricht, the netherlands'       ,  # 'q24250852 (1806-1859) soldier and public
        'euraxi',
        'fengxi su',
        'florian beigel'                ,  # 'q19661459 architect based in london
        'gammacan',
        'george brewer'                 ,  # 'q5537230 british writer
        'grant jones'                   ,  # 'q5596289 american landscape architect
        'holger thiele'                 ,  # 'q562164 american astronomer
        'hongwen xu',
        'irenbe',
        'james baumgartner, md'         ,  # 'q6133274 american logician
        'jason bryant',
        'jeffrey browning'              ,  # 'q16208757 american ultramarathon runner
        'jeffrey kramer, md'            ,  # 'q6176107 american actor and producer
        'jennifer gay'                  ,  # 'q6178342 british television announcer
        'jerry zimmerman'               ,  # 'q6184702 american baseball players
        'joel lavine',
        'jonathan berman',
        'joseph dib',
        'joseph hazelton'               ,  # 'q6283869 american actor
        'julian pine',
        'julie wang',
        'justin watts'                  ,  # 'q16233655 american basketball player
        'k. lieb',
        'kaitlyn kelly, md'             ,  # 'q437226 american pornographic actress
        'kaitlyn kelly, md'             ,  # 'q437226 american pornographic actress
        'kathryn stephenson'            ,  # 'q6377129 american physician
        'kelly tanner'                  ,  # 'q16194830 american stock car racing driv
        'kirsten williams'              ,  # 'q6416126 canadian actress
        'koyce fox'                     ,  # 'q6297486 american writer
        'lfce',
        'linda carlson'                 ,  # 'q11832719 actress
        'lindsey miller'                ,  # 'q6552896 american judge
        'lisa brenner'                  ,  # 'q461378 american actress
        'marc breton'                   ,  # 'q3287847 french actor
        'margarida vieira',
        'maria sklodowska-curie institute - oncology center'       ,  # 'q1054401 architectural structure
        'mary fristad'                  ,  # 'q45882355 american psychologist and acad
        'michael j. rosen, md.'         ,  # 'q6831494 american writer
        'michael rosenbaum'             ,  # 'q311613 american actor
        'michelle lopez',
        'mindframe, inc.'               ,  # 'q42607297 movie theater in dubuque, iowa
        'myocor',
        'nailab, kenya'                 ,  # 'q6959471 businessperson
        'nancy bauman',
        'natalie allen'                 ,  # 'q17438529 american presenter, anchor and
        'natasha duke'                  ,  # 'q28802903 animator
        'obstetrix',
        'oscar goodman, jr.'            ,  # 'q515259 american attorney and politici
        'ovo r & d',
        'paul carlson'                  ,  # 'q15491063 american physician
        'rachel little',
        'ronald hoffman'                ,  # 'q7364939 american physician
        'sally falk'                    ,  # 'q7405128 american anthropologist
        'salvador gil-vernet',
        'samantha harrison',
        'sharon walsh'                  ,  # 'q461080 american tennis player
        'stefan g. hofmann'             ,  # 'q37837264 american psychology professor
        'stephen trokel'                ,  # 'q1599537 american physicist
        'stephens & associates, inc.',
        'sunil rao'                     ,  # 'q7640340 actor
        'syral',
        'tobias werther',
        'tony eissa'                    ,  # 'q22688616 actor
        'tracie collins, md, mph'       ,  # 'q23932108 actor
        'tularik',
        'vesalio',
        'victoria gomez',
        'vincent kan',
        'yijing he',
      ]
    end
  end
end
