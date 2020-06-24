module Lookup
  class Organization < SuperLookup
    self.table_name = 'lookup.organizations'

    def self.source_data
      # The model that will be used as the source of info
      "Project::CdekOrganization"
    end

    def self.qcode_for(search_name)
      return if search_name.nil?
      results = self.where('qcode is not null and downcase_name = ?',search_name.downcase)
      return results.first.qcode if results.size > 0
      preferred_name = Project::CdekSynonym.where('downcase_name = ?',search_name.downcase).pluck(:preferred_name)
      if preferred_name.size == 0
        return nil
      else
        results = self.where('downcase_name = ?', preferred_name.first.downcase)
        return results.first.qcode if results.size > 0
      end
    end

    def self.populate
      self.populate_for_model("Project::CdekOrganization")
    end

    def populate_other_attribs
      mgr = Util::WikiDataManager.new
      org_props = mgr.org_properties_for(self.qcode)
      org_props.each{|prop_hash|
        key = prop_hash.keys[0]
        val = prop_hash[key]
        case key
        when :qs_world_univ_id
          self.qs_world_univ_id = val
        when :arwu_univ_id
          self.arwu_univ_id = val
        when :times_higher_ed_id
          self.times_higher_ed_id = val
        when :grid_id
          self.grid_id = val
        when :countryLabel
          self.country = val
        end
        self.save!
      }
    end

    def self.impossible_descriptions
      super + [ '1645-1718', '7th century Scottish martyr and saint', 'ability of an individual or organization to guide other individuals, teams, or entire organizations',
      'award', 'African Grey Parrot research subject', 'Airport in Pennsylvania', 'American martial artist', 'Argentine lawyer', 'Australian swimmer', 'American cricketer',
      'American landscape architect', 'biological process','boxer', 'botanist', 'bus stop', 'clinical trial', 'American software consultant', 'American television journalist',
      'Canadian broadcaster', 'Congressional Research Service report','data set','British rowing club','chemical compound','Chilean painter (1936–2011)','Chilean weightlifter',
      'Chinese photographer', 'Chinese translator', 'Chinese artist','Chinese entomologist','the formation of blood cellular components',
      'collective term for all approaches to prepare, support, and help individuals, teams, and organizations in making organizational change','cyclist','freestyle skier',
      'class of chemical compounds', 'cricketer','cultural monument of Panama','culture collection in Asia','dish','Egyptian architect','English cricketer','female parent',
      'Flemish painter (1612-1661)','graduate academic degree in Education', 'disease','disease, questionable disease','gene','firefighter','group or class of chemical substances',
      'function responsible for effective communications among participants within an organization','genus of insects', 'genus of plants','German rapper', 'German sculptor',
      'German speed skater','German left-wing activist','hybrid of citrus fruit','King of Denmark, Norway and Sweden','male given name','patent holder','Peerage person ID=454092',
'Peerage person ID=532492','people and organizations that have mutually associated toward a common goal or purpose','person, CBDB = 117973','person, CBDB ID = 406026',
      'Italian journalist','journal', 'human','human settlement','hypothetical technology','item of collection or exhibition','kinship','mythical character','novel by Charles Bukowski',
      'number','painter', 'person who makes drawings (artist/cartoonist/drafter/illustrator)', 'legal case','legal case, United States Supreme Court case, United States Supreme Court decision',
      'legal case, United States Supreme Court decision','literary work','metro station','musical group', 'mythological Greek character','non-commercial activity','non-fiction book','profession','protein',
       'Q1072319, passenger train','Q12806826','Q2945729','Q43371093','rapid transit railway line','relation','President of El Salvador','Qing dynasty person CBDB=351987','Railway line of Beijing Subway',
       'scheduling algorithm','scientific article','scientific journal','ship','spring','stadium','supercomputer', 'saxophonist', 'subspecialty of internal medicine concerned with the study of neoplasms',
       'series in the National Archives and Records Administration''s holdings','US-American artist (1909-1992)',
       'system', 'taxon', 'terrorist organization, guerrilla movement', 'unisex given name', 'Spanish Theologian', 'study of successful organizational change and performance',
       'Tang dynasty person CBDB = 151668', 'Tang dynasty person CBDB = 193477', 'neighborhood',
       'the chemical reactions and pathways resulting in the formation of substances; typically the energy-requiring part of metabolism in which simpler substances are transformed into more complex ones',
       'The executive of Ukraine, consisting of the prime minister and cabinet ministers.','TV presenter','Region of the Czech Republic',
       'The opposite of nofollow. When there is no impediment, warning or indication discouraging search engines in the act of following a hyperlink.',
       'the second xiangya hospital of csu'
      ]
    end

    def self.names_to_ignore
      ['biosyn', 'ud-genomed kft.', 'sydney children''s hospital, randwick', 'clinical hospital #15 clinical hospital #15 named after o.m.filatov, moscow, russia']
    end

    def self.possible_descriptions
      [
       'organization',
       'pharmaceutical corporation',
       'medical research organization',
       'company',
       'academic institution',
       'university',
       'medical research',
       'hospital',
       'site',
       'research',
       'education'
      ]
    end

    def self.names_to_ignore
      ['ud-genomed kft.']
    end

    def self.predefined_qcode
      # First part is list of facilities.name ordered by most common.  Next most common sponsor orgs ordered by most common.
      {
        'GSK Investigational Site'                  => 'Q212322',
        'Novartis Investigative Site'               => 'Q507154',
        'Novartis Investigator Site'                => 'Q507154',
        'Pfizer Investigational Site'               => 'Q206921',
        'National Institutes of Health Clinical Center, 9000 Rockville Pike'  => 'Q390551',
        'Novo Nordisk Investigational Site'         => 'Q818846',
        'Boehringer Ingelheim Investigational Site' => 'Q699532',
        'Clinical Research Center Kiel GmbH'        => 'Q50038397',
        'Nycomed Deutschland GmbH'                  => 'Q667442',
        'Nycomed Deutschland GmbH, 78467 Konstanz, Germany' => 'Q667442',
        '"Nycomed Deutschland GmbH"'                => 'Q667442',
        'Mayo Clinic'                               => 'Q1130172',
        'Massachusetts General Hospital'            => 'Q126412',
        'Sanofi-Aventis Administrative Office'      => 'Q158205',
        'Washington University School of Medicine'  => 'Q7972509',
        'ImClone Investigational Site'              => 'Q6001772',
        'Memorial Sloan Kettering Cancer Center'    => 'Q1808012',
        'Memorial Sloan-Kettering Cancer Center'    => 'Q1808012',
        'Medical University of South Carolina'      => 'Q6806451',
        'Seoul National University Hospital'        => 'Q4403855',
        'Seoul National University Bundang Hospital' => 'Q7451677',
        'Beth Israel Deaconess Medical Center'      => 'Q4897536',
        'Alkermes Investigational Site'             => 'Q4727688',
        'Dana-Farber Cancer Institute'              => 'Q1159198',
        'National Taiwan University Hospital'       => 'Q1418766',
        'Northwestern University'                   => 'Q309350',
        'University of Texas MD Anderson Cancer Center' => 'Q1525831',
        'Roswell Park Cancer Institute'             => 'Q7370121',
        'Synergy Research Site'                     => 'Q59503183',
        'University of Alabama at Birmingham'       => 'Q1472663',
        'University of Pennsylvania'                => 'Q49117',
        'Samsung Medical Center'                    => 'Q624119',
        'Columbia University Medical Center'        => 'Q2415975',
        'Vanderbilt University Medical Center'      => 'Q7914455',
        "Brigham and Women's Hospital"              => 'Q2900977',
        'University of Michigan'                    => 'Q230492',
        'Cleveland Clinic'                          => 'Q4117596',
        'Cleveland Clinic Foundation'               => 'Q4117596',
        'Asan Medical Center'                       => 'Q4803501',
        'Baylor College of Medicine'                => 'Q2892284',
        "Cincinnati Children's Hospital Medical Center" => 'Q5120231',
        'Rush University Medical Center'            => 'Q1535116',
        'Emory University'                          => 'Q621043',
        "Children's Hospital of Philadelphia"       => 'Q4569202',
        'University of Florida'                     => 'Q501758',
        'University of Minnesota'                   => 'Q238101',
        'Duramed Investigational Site'              => 'Q59503405',
        'University of Chicago'                     => 'Q131252',
        'Stanford University'                       => 'Q41506',
        'Fox Chase Cancer Center'                   => 'Q5476635',
        'University of Rochester'                   => 'Q149990',
        'Johns Hopkins University'                  => 'Q193727',
        'University of Nebraska Medical Center'     => 'Q7895888',
        'University of Oklahoma Health Sciences Center' => 'Q7896014',
        'University of Kansas Medical Center'       => 'Q33526980',
        'University of Mississippi Medical Center'  => 'Q7895818',
        'Dana Farber Cancer Institute'              => 'Q1159198',
        'Connective Tissue Oncology Society'        => 'Q50035934',
        'Efficient Pharma'                          => 'Q30287280',
        'Government of Egypt'                       => 'Q8496243',
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
        'Boehringer Ingelheim'                     => 'Q699532',
        'Eli Lilly and Company'                    => 'Q632240',
        'Bristol-Myers Squibb'                     => 'Q266423',
        'National Institute of Mental Health (NIMH)' => 'Q1967405',
        'National Institutes of Health (NIH)'      => 'Q390551',
        'Bayer'                                    => 'Q152051',
        'National Institute on Drug Abuse (NIDA)'  => 'Q6973751',
        'University of California, San Francisco'  => 'Q1061104',
        'Assistance Publique - Hôpitaux de Paris'  => 'Q2867205',
        'National Institute of Diabetes and Digestive and Kidney Diseases (NIDDK)' => 'Q29220409',
        'Novartis'                                 => 'Q507154',
        'Eunice Kennedy Shriver National Institute of Child Health and Human Development (NICHD)' => 'Q5409765',
        'University of Pittsburgh'                 => 'Q235034',
        'Genentech, Inc.'                          => 'Q899140',
        "Nicklaus Children's Hospital"             => 'Q6827285',
        "Ospedale Niguarda Ca' Granda"             => 'Q3886620',
        'Loyola University Medical Center'         => 'Q6694611',
        'Fred Hutchinson Cancer Research Center'   => 'Q1452369',
        'Montefiore Medical Center'                => 'Q6905066',
        'University of Toyama'                     => 'Q1147924',
        'Duke University'                          => 'Q168751',
        'Duke University Medical Center'           => 'Q30279912',
        'Duke University Hospital'                 => 'Q5312894',
        'Duke University Health System'            => 'Q5312891',
        'Duke Cancer Institute'                    => 'Q4892499',
        'Duke Raleigh Hospital'                    => 'Q50036571',
        'Duke University School of Medicine'       => 'Q4119601',
        'Duke Eye center'                          => 'Q96149612',
        'Duke Eye Center'                          => 'Q96149612',
        'Duke Eye Center, Duke University'                 => 'Q96149612',
        'Duke Eye Center, Duke University Health System'   => 'Q96149612',
        'Duke Eye Center, Duke University Medical Center'  => 'Q96149612',
        'Duke University, Duke Eye Center'         => 'Q96149612',
        'Duke University School of Medicine / Dept. of Ophthalmology (Duke Eye Center)' => 'Q96149612',
        'Duke Univ Medical Center/Duke Eye Center' => 'Q96149612',
        'Duke Cancer Center'                       => 'Q96149477',
        'Duke Cancer Center Cary'                  => 'Q96149477',
        'Duke Cancer Center Cary ( Site 0010)'     => 'Q96149477',
        'Duke Cancer Center, Duke University'      => 'Q96149477',
        'Duke Cancer Center, Duke University Medical Center'   => 'Q96149477',
        'Duke Cancer Center /ID# 207547'                       => 'Q96149477',
        'Duke Cancer Center ( Site 0010)'                      => 'Q96149477',
        'Duke Cancer Center ( Site 0028)'                      => 'Q96149477',
        'Duke Health, Duke Cancer Center'                      => 'Q96149477',
        'Duke University Heath System, Duke Cancer Center'     => 'Q96149477',
        'Duke University Medical Center Dept. of Duke Cancer Center'       => 'Q96149477',
        'Duke University Medical Center Dept. of Duke Cancer Center(2)'    => 'Q96149477',
        'Duke University Medical Center - Duke Cancer Center'              => 'Q96149477',
        'Duke University Medical Center-Duke Cancer Center'                => 'Q96149477',
        'Duke University Medical Center, Duke Cancer Center'               => 'Q96149477',
        'Duke University Medical Center/Duke Cancer Center'                => 'Q96149477',
        'DUMC/Duke Cancer Center'                  => 'Q96149477',
        'Duke University Eye Center'               => 'Q96149612',
        'Duke Human Vaccine Institute - Duke Vaccine and Trials Unit' => 'Q96150080',
        'Duke Health'                              => 'Q5312891',
        'Duke Child and Family Center'             => 'Q96150744',
        'Duke Child & Family Study Center'       => 'Q96150744',
        'Duke Child And Family Study Center'       => 'Q96150744',
        'Duke Child and Family Study Center//Duke Health Behavior Neuroscience Research Program' => 'Q96150744',
        'Duke Child & Family Studies Center; Duke University Medical Center'   => 'Q96150744',
        'Duke University Medical Center - Duke Child and Family Study Center'  => 'Q96150744',
        'Duke University Medical Center, Duke Child and Family Study Center'   => 'Q96150744',
        'Duke University Medical Center, Duke Cancer Institute' => 'Q4892499',
        'Duke University Health Systems'           => 'Q5312891',
        'Duke University Hospital Medical Center'  => 'Q30279912',
        'Duke Clinical Research Institute'         => 'Q56474016',
        'Duke Medical Center'                      => 'Q30279912',
        "Duke Children's Hospital"                 => 'Q30279914',
        "Duke Children"                            => 'Q30279914',
        "Duke Children's Health Center"            => 'Q30279914',
        "Duke Children's Health Center, Pediatric Infectious Diseases" => 'Q30279914',
        "Duke Children's Hospital"                 => 'Q30279914',
        "Duke Children's Hospital and Health Center"  => 'Q30279914',
        "Duke Children's Hospital and Health Center; Duke Cancer Institute" => 'Q30279914',
        "Duke Children's Hospital and Medical Center" => 'Q30279914',
        "Duke Children's Hospital & Health Center"    => 'Q30279914',
        'Duke University Cancer Center'            => 'Q96149477',
        'Duke UMC 3, Duke University Medical Center' => 'Q30279912',
        'Duke University Health System Preston Robert Tisch Brain Tumor Center' => 'Q96150792',
        'Duke University Medical Center Preston Robert Tisch Brain Tumor Center' => 'Q96150792',
        'Duke University Medical Center, Preston Robert Tisch Brain Tumor Center' => 'Q96150792',
        'Duke University Medical Center - The Preston Robert Tisch Brain Tumor Center' => 'Q96150792',
        'Duke University Medical Center; The Preston Robert Tisch Brain Tumor Center' => 'Q96150792',
        'Duke University - Preston Robert Tisch Brain Tumor Center' => 'Q96150792',
        'Duke University, The Preston Robert Tisch Brain Tumor Center' => 'Q96150792',
        'Preston Robert Tisch Brain Tumor Center at Duke' => 'Q96150792',
        'Preston Robert Tisch Brain Tumor Center at Duke University' => 'Q96150792',
        'Preston Robert Tisch Brain Tumor Center at Duke University Medical Center' => 'Q96150792',
        'The Preston Robert Tisch Brain Tumor Center at Duke' => 'Q96150792',
        'The Preston Robert Tisch Brain Tumor Center' => 'Q96150792',
        'The Preston Robert Tisch Brain Tumor Center at Duke' => 'Q96150792',
        'The Preston Robert Tisch Brain Tumor Center at Duke University Medical Center' => 'Q96150792',
        'The Preston Robert Tisch Brain Tumor Center; Duke University Medical Center' => 'Q96150792',
      }
    end
  end
end
