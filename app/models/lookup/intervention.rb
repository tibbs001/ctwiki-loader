module Lookup
  class Intervention < SuperLookup
    self.table_name = 'lookup.interventions'

    def self.source_data
      # The ctgov model that will be used as the source of info
      BrowseIntervention
    end

    def self.label
      :mesh_term
    end

    def self.impossible_descriptions
      super + [
       'abstract',
       'actress',
       'aircraft',
       'airplane',
       'army general',
       'artillery guns',
       'artwork',
       'aviation squadron',
       'book',
       'brand of footwear',
       'clinical trial',
       'company',
       'computer network protocol',
       'conference',
       'corporation',
       'dedicated harbour',
       'desk in the white house',
       'disease',
       'driving license',
       'drug allergy',
       'episode',
       'etching',
       'exhibition',
       'extended play',
       'farmhouse',
       'galaxy',
       'governmental agency',
       'hospitals',
       'internet bank',
       'interpro family',
       'light table is a viewing device',
       'literature review',
       'loss of one or more sounds from the beginning of a word',
       'mountain in',
       'natural number',
       'newspaper',
       'non-profit',
       'norwegian',
       'organization',
       'motorway',
       'norwegian bokmål',
       'opera',
       'novel by',
       'person',
       'place for conducting research',
       'play by ',
       'plot device',
       'pokémon move',
       'political party',
       'presenter',
       'proposed ethernet standard',
       'publisher',
       'relay communications satellites',
       "records administration's holdings",
       'report',
       'rock band',
       'route',
       'rural commune',
       'school in',
       'scientific study',
       'secure website',
       'short story',
       'sill of a door',
       'single by',
       'song by',
       'specialist',
       'store which sells nutrition supplements',
       'stratford-upon-avon',
       'teleplay',
       'television series',
       'technical information service',
       'unicode technical standard',
       'unincorporated community',
       'university',
       'watercourse',
       'webcomic',
       'wikipedia',
       'urban vehicle',
       'zoroaster',
      ].flatten
    end

    def self.names_to_ignore
       ['1  pf',
        'acoustic',
        'aline ha',
        'biological agents',
        'blueberry tea',
        'business as usual',
        'business-as-usual',
        'cab la',
        'cbt4cbt',
        'computer algorithm',
        'computer-assisted counseling',
        'computer-assisted gdft',
        'computer-based clinical decision support.',
        'computer-assisted cognitive training',
        'computer-based alcohol reduction intervention',
        'computer-based psychoeducational intervention',
        'computer-based confrontation with dysfunctional beliefs',
        'computer-based target pursuit task (created using e-prime software) and visual-feedback handgrip force transducer (currentdesigns 2012).', 'computer-facilitated hiv intervention',
        'concord grape juice',
        'cpt-c',
        'cr-exp',
        'dance group',
        'delayed graft',
        'vitamin-k-antagonists',
        'educational support',
        'endovascular aneurysm repair',
        'eprime',
        'foyc',
        'griess,',
        'health intervention',
        'hvla',
        'lbal',
        'mastermed',
        'milk drink',
        'multimedia group',
        'no tae',
        'numerical simulation',
        'open repair',
        'optive™',
        'pep-pal',
        'pop-q',
        'quest',
        'screen-educate and intensify treatment',
        'social adaptation',
        'solace',
        'standard protocol',
        'tertiary care',
        'theatre workshops',
        'therapeutic touch',
        'walking, walking',
        'webmd',
       ]
    end

    def self.possible_descriptions
      [
       'drug',
       'pharmaceutical drug',
       'device',
       'treatment',
       'treatment for a disease',
       'treatment for a medical condition',
       'intervention',
       'chemical compound',
      ]
    end

    def self.predefined_qcode
      {
        '1000 mg acetylsalicylic acid (Aspirin, BAYE4465)'          =>'Q18216',
        '500 mg acetylsalicylic acid (Aspirin, BAYE4465)'          =>'Q18216',
        'acetylsalicylic acid'          =>'Q18216',
        'acetylsalicylic acid 75 mg'          =>'Q18216',
        'acetylsalicylic acid (asa)'          =>'Q18216',
        'acetylsalicylic acid (asa) therapy'          =>'Q18216',
        'acetylsalicylic acid, clopidogrel bisulfate and/or warfarin, apixaban, rivaroxaban, dabigatran'          =>'Q18216',
        'acetylsalicylic acid started for 24 hours before surgery'          =>'Q18216',
        'acetylsalicylic acid stayed for 5 days before surgery'          =>'Q18216',
        'aspirin (acetylsalicylic acid)'          =>'Q18216',
        'association: acetylsalicylic acid (500mg), sodium bicarbonate (1625) and citric acid (965)'       =>'Q18216',
        'bausch & lomb renu multiplus multi-purpose solution' => 'Q50573431',
        'bausch & lomb multipurpose solution - no rub care' => 'Q50573431',
        'bausch & lomb renu multiplus multi-purpose solution packaged in the currently marketed resin bottle.' => 'Q50573431',

        'buffered acetylsalicylic acid'          =>'Q18216',
        'cardiovascular fixed dose combination pill (acetylsalicylic acid, simvastatin and ramipril)'          =>'Q18216',
        'cigarette'                              => 'Q1578',
        'clopidogrel+acetylsalicylic acid'       =>'Q18216',
        'inderal (drug), acetylsalicylic acid (drug)'          =>'Q18216',
        'nitric oxide-releasing acetylsalicylic acid derivative' =>'Q18216',
        'Simvastatin, ramipril, acetylsalicylic acid'           =>'Q18216',
        'azd6738 and olaparib'                   => 'Q27896182',
        'bevacizumab'                            => 'Q413299',
        'carboplatin'                            => 'Q415588',
        'celestamine'                            => 'Q59790585',
        'cheese'                                 => 'Q10943',  # NCT02836106
        'cisplatin'                              => 'Q412415',
        'cohort 2, ceplene and proleukin'        => 'Q29004963',
        'control'                                => 'Q2148398',
        'cyclophosphamide'                       => 'Q408524',
        'dexamethasone'                          => 'Q408524',
        'endurance training plus resistant training' => 'Q362854',
        'electrical impedance myography (eim)'   => 'Q5357720',
        'everolimus + letrozole'                 => 'Q421052',
        'first-line i/v-levetiracetam'           => 'Q26720719',  # NCT00603135
        'heat pad application'                   => 'Q59506412',
        'iv dexamethasone therapy'               => 'Q422252',
        'inv-144'                                => 'Q59795917',
        'laboratory biomarker analysis'          => 'Q59790130',  # already was biomarker (Q864574)  Added entity specifically for this
        'low frequency therapeutic ultrasound'   => 'Q59773581',  # added this treatment to wikidata
        'monthly ranibizumab'                    => 'Q414270',
        'msm'                                    => 'Q423842',
        'niacin/laropiprant/simvastatin (n/lrpt/sim)'  => 'Q134658',
        'half dose oxytocin'                     => 'Q169960',
        'paclitaxel'                             => 'Q423762',
        'phase ii - gm.cd40l.ccl21 vaccinations' => 'Q192995',
        '10 mg/kg IV phenobarbital in 100 ml saline'  => 'Q407241',
        'pimodivir'                              => 'Q27276370',
        'placebo'                                => 'Q269829',
        'placebo oral capsule'                   => 'Q269829',
        'placebos'                               => 'Q269829',
        'prp injection'                          => 'Q59791666',
        'pulpectomy for primary molars + 3mixstatin' => 'Q3410767',
        'radiation therapy'                      => 'Q180507',
        'rituximab'                              => 'Q412323',
        'r-mant'                                 => 'Q412323',  #  NCT02390869  other name for rituximab
        'st. johns wort'                         => 'Q156935',
        'tdm1'                                   =>'Q3997863',  # NCT02135159
        'trigonella foenum-graecum seed extract' => 'Q59773585',  #  added this treatment

     }
#     Q20459    | portable device used to generate a flame           | Cigarette

    end

  end
end
