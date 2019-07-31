module Lookup
  class Chemical < SuperLookup
    self.table_name = 'lookup.chemicals'

    def self.names_to_ignore
      ['e-do', 'sade-free rate']
    end

    def self.possible_descriptions
      [
       'class of drug',
       'chemical compound',
       'chemical element',
       'drug',
       'enzyme',
      ]
    end

    def self.source_data
      Pubmed::Chemical
    end

    def self.impossible_descriptions
      super + [
       'abstract',
       'actress',
       'airplane',
       'army general',
       'artillery guns',
       'artwork',
       'aviation squadron',
       'book',
       'brand of footwear',
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
        '(+)-JQ1 compound' => 'Q3156953',
        '1-Propanol'                  => 'Q14985',
        '1-amino-1,3-dicarboxycyclopentane' => 'Q4650770',
        'Antibodies, Viral'           => 'Q66021534',
        'Cetylpyridinium'             => 'Q27115152',
        'Chlorhexidine'               => 'Q15646788',
        'DNA, Viral'                  => 'Q64829422',
        'Hemoglobins'                 => 'Q43041',
        '1-hydroxypyrene'             => 'Q21099650',
        '10-propargyl-10-deazaaminopterin' => 'Q637059',
        '11-beta-Hydroxysteroid Dehydrogenase Type 1' => 'Q1145920',
        '11-beta-Hydroxysteroid Dehydrogenase Type 2' => 'Q1145920',
        '11-dehydro-thromboxane B2'   => 'Q2806929',
        '2,3-dinor-thromboxane B2'    => 'Q27162208',
        '2,4-dinitrophenylhydrazine'  => 'Q209227',
        '2-Propanol'                  => 'Q16392',
        '2-chloro-5-nitrobenzanilide' => 'Q27077962',
        '25-hydroxyvitamin D'      => 'Q56467915',
        'Papillomavirus Vaccines'  => 'Q900189',
        '27-hydroxycholesterol'    => 'Q3598427',
        '3-Iodobenzylguanidine'    => 'Q3154058',
        '3-nitrotyrosine'          => 'Q412383',
        '4-Aminopyridine'          => 'Q372539',
        '4-cresol sulfate'         => 'Q27156456',
        '4-hydroxy-2-nonenal'      => 'Q229982',
        '5-Methylcytosine'         => 'Q238563',
        '5-azacytosine'            => 'Q27139948',
        '7-dehydrocholesterol'     => 'Q139350',
        '8-hydroxyguanosine'       => 'Q4644278',
        '8-Bromo Cyclic Adenosine Monophosphate' => 'Q4644267',
        'ABCB1 protein, human'     => 'Q21163344',
        'ABCG2 protein, human'     => 'Q4650095',
        'ABCB6 protein, human'     => 'Q18034991',
        'ABO Blood-Group System'   => 'Q188010',
        'AC133 Antigen'            => 'Q1498674',
        'ADAMTS13 Protein'         => 'Q14873945',
        'ADAMTS13 protein, human'  => 'Q14873945',
        'ADIPOQ protein, human'    => 'Q14864060',
        'AICA ribonucleotide'      => 'Q2817102',
        'AIDS Vaccines'            => 'Q1479804',
        'AKT1 protein, human'      => 'Q17816452',
        'ALB protein, human'       => 'Q424232',
        'AMP-Activated Protein Kinases'  => 'Q295240',
        'Acetaminophen'            => 'Q57055',
        'Sulfur'                   => 'Q682',
        'Viral Vaccines'           => 'Q58624061',
        'Zinc'                     => 'Q758',
      }
    end
  end
end
