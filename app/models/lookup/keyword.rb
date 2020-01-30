module Lookup
  class Keyword < SuperLookup
    self.table_name = 'lookup.keywords'

    def self.source_data
      # The model that will be used as the source of info
      "Ctgov::Keyword"
    end

    def self.names_to_ignore
      ['e-do', 'sade-free rate','0177','11-041','11-101','11-104','11-105','11-106','11-108','1000 days', '11-150',
       '11q','11-136','qqwqb','12-116','12-117','12-121','12-124','11q','124-i','14-101','18fdg','10 mg','10q23.3','11q-deleted relapsed/refractory chronic lymphocytic leukaemia',
       '24-hr diet recall','24 hour urine','24-hour dietary recall','24-hour dietary recalls','24-hour energy intake','24-hour pad test','24-hour urine','24-hout urine',
      '24-h recall','24-h urine composition''24-week follow-up','2nd line','2nd trimester','30 day mortality', '30-day mortality', '30 day readmission rate','3d acquisition',
      '3d guide','30 mg','95gy in 35 fractions','5 years','97-127','abcsg','ablc','abnormal fasting glucose','abnormal gait','academic stress','acupression','iatta', 'abdominal operation','ict support','accelerated healing','adaptable','admissions','i-cam','abstain','acld','abuse report','healthy meals','da-90','creative arts',
      'gsk pandemic candidate vaccine','gorham','everest','g72','cravings','hattr','frost injury','gow-gates nerve block','cup of tea','cramps','especialista',
      'food records', 'gargle','hcmv infection','gluten immunogenic peptides','current disease','congenital long qt','concurrent chemoradiation therapy'
      ]
    end

    def self.possible_descriptions
      [
       'disease',
       'medical condition',
       'disorder',
       'defect',
       'disturbance',
      ]
    end

    def self.impossible_descriptions
      super + [
       'abstract',
       'actress',
       'airplane',
       'army general',
       'artillery guns',
       'artwork',
       'asteroid',
       'business',
       'aviation squadron',
       'book',
       'brand of footwear',
       'clinical commissioning group',
       'clinical trial',
       'company',
       'conference',
       'driving license',
       'episode',
       'etching',
       'exhibition',
       'farmhouse',
       'galaxy',
       'governmental agency',
       'grammatical case',
       'hospitals',
       'internet bank',
       'interpro family',
       'journal',
       'light table is a viewing device',
       'literature review',
       'mountain in',
       'non-profit',
       'norwegian',
       'organization',
       'motorway',
       'novel by',
       'person',
       'place for conducting research',
       'pokémon move',
       'presenter',
       'proposed ethernet standard',
       'publisher',
       'report',
       'rock band',
       'route',
       'rural commune',
       'scholarly article',
       'short story',
       'single by',
       'specialist',
       'store which sells nutrition supplements',
       'teleplay',
       'television series',
       'technical information service',
       'town in ',
       'unincorporated community',
       'university',
       'watercourse',
       'webcomic',
       'extended play',
       'wikipedia',
       'zoroaster',
      ].flatten
    end

    def self.predefined_qcode
      # Most common - ordered list.
      {
        'HIV'                                      => 'Q15787',
        'Obesity'                                  => 'Q12174',
        'Pharmacokinetics'                         => 'Q323936',
        'Depression'                               => 'Q42844',
        'Safety'                                   => 'Q10566551',
        'Cancer'                                   => 'Q12078',
        'Pain'                                     => 'Q81938',
        'Exercise'                                 => 'Q219067',
        'COPD'                                     => 'Q199804',
        'Diabetes'                                 => 'Q12206',
        'Quality of Life'                          => 'Q13100823',
        'Children'                                 => 'Q7569',
        '10% urea'                                 => 'Q48318',
        '11 beta-hydroxysteroid dehydrogenase type 1' =>  'Q1145920',
        '11-beta-hydroxysteroid dehydrogenase type 1' =>  'Q1145920',
        '11beta-hydroxysteroid dehydrogenase type 1' => 'Q1145920',
        '23andme'                                    => 'Q216272',
        '25-hydroxy vitamin d'                       => 'Q139307',
        '25 hydroxy vitamin d'                       => 'Q139307',
        '25-hydroxyvitamin d3'                       => 'Q139307',
        '25ohd'                                      => 'Q139307',
        '25-oh d'                                    => 'Q139307',
        '2hr -75gm oral glucose tolerance test'      => 'Q1501412',
        '3d computed tomography'                     => 'Q32566',
        '68ga-dotanoc pet'                           => 'Q83445886',
        '68ga-dotanoc pet/ct'                        => 'Q83445886',
        '68ga-dotanoc'                              => 'Q83445886',
        'ga68-citrate'                              => 'Q27288064',
        '6-aminocaproic acid'                       =>'Q27132370',
        'abdominal'                                 => 'Q9597',
        'frmi'                                      => 'Q903809',
      }
    end
  end
end
