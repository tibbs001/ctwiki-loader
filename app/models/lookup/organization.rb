module Lookup
  class Organization < SuperLookup
    self.table_name = 'lookup.organizations'

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
      self.populate_for_model(Project::CdekOrganization)
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
        'Duke University Medical Center'            => 'Q168751',
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
        'Duke University'                          => 'Q168751',
        'Novartis'                                 => 'Q507154',
        'Eunice Kennedy Shriver National Institute of Child Health and Human Development (NICHD)' => 'Q5409765',
        'University of Pittsburgh'                 => 'Q235034',
        'Genentech, Inc.'                          => 'Q899140',
        "Nicklaus Children's Hospital"             => 'Q6827285',
        "Ospedale Niguarda Ca' Granda"             => 'Q3886620',
        'Loyola University Medical Center'         => 'Q6694611',
        'Fred Hutchinson Cancer Research Center'   => 'Q1452369',
        'Montefiore Medical Center'                => 'Q6905066',
      }
    end
  end
end
