module Util
  class StudyPrepper < Util::Prepper

    def self.source_model_name
      # to do  figure this out later - needed by both class and instance methods - eliminate the duplication
      Ctgov::Study
    end

    def studies_to_investigate
      # can't load these into wikidata because the study title is already assigned to an entity.  we should investigate.
      ['NCT00363519','NCT00383227','NCT00394576',
       'NCT00575068', # 'Safety and Efficacy of IDEC-114 in the Treatment of Non-Hodgkins Lymphoma'
       'NCT00660517', # A Study to Evaluate the Safety and Effectiveness of a Nasal Spray to Treat Seasonal Allergies (2007-12-31)
       'NCT00912665', # Regulation of Optic Nerve Head Blood Flow During Combined Changes in Intraocular Pressure and Arterial Blood Pressure (2009-07-31)
       'NCT01111552', # Study to Evaluate the Efficacy, Safety and Tolerability of an Oral Aripiprazole/Escitalopram Combination Therapy in Patients With Major Depressive Disorder (MDD) (2010-07-31)
       'NCT01218711', # Bioequivalence Study of Losartan Potassium and Hydrochlorothiazide (100 mg / 25 mg Tablet) [Test Formulation, Torrent Pharmaceuticals Ltd., India] Versus Hyzaar® (100 mg / 25 mg Tablet) [Reference Formulation, Merck & Co., Inc., USA] in Healthy
       'NCT01465633', # Bioavailability Investigations of Thyronajod Mite Tablets of Dosage Strengths 50 μg Levothyrox-ine/75 μg Iodine, and 100 μg Levothyroxine/75 μg Iodine vs. a Levothyroxine Drinking-Solution: A Randomised Cross Over Study in Healthy Male Individua
       'NCT01780506', # Study to Evaluate the Safety and Efficacy of E/C/F/TAF (Genvoya®) Versus E/C/F/TDF (Stribild®) in HIV-1 Positive, Antiretroviral Treatment-Naive Adults
       'NCT02106637', # Early In-hospital Initiation of Pharmacotherapy for Smoking Cessation, Patients After ACS
       'NCT02271893',
       'NCT02277405', # Pediatric Intubation During Resuscitation
       'NCT02308007', # Multi-Center Study of New Medications to Treat Vaginal Infections (2015-06-30)
       'NCT02750475', # Human Phototoxicity Test (2016-05-02)
       'NCT02803008', # Sun Protection Factor Assay (2015-10-29)
       'NCT02803034', # Sun Protection Factor Assay (2015-11-09)
       'NCT02803047', # Sun Protection Factor Assay (2015-11-09)
       'NCT02803099', # Sun Protection Factor Assay (2015-11-18)
       'NCT02822248', # Sun Protection Factor Assay (2015-11-19)
       'NCT03030937', # Clinical Trial to Compare Apatinib Plus Irinotecan Versus Single Irinotecan as Second-line Treatment in AGC or EGJA
       'NCT03127878', # Effects of Upper-limb Training Addition to a Conventional ET Program on PA Level and ADL Performance.
       'NCT03481413', # All Inclusive KODEX - EPD™ Study Patient Specific Optimized Therapy (PSOT) Study
       'NCT03909958', # The Impact of Electroacupuncture on Clinical Effect,Brain Structural and Functional Changes on Spinal Cord Injury
       'NCT03919136', # Wrist Worn Blood Pressure Measurement
       'NCT03983928', # Study of TQB2450 Combined With Anlotinib in the Treatment of Mutation Positive Lung Cancer
       'NCT03987620', # Efficacy and Safety of Oral Ibrexafungerp (SCY-078) vs. Placebo in Subjects With Acute Vulvovaginal Candidiasis
       'NCT04051112', # Study With SCB-313 (Recombinant Human TRAIL-Trimer Fusion Protein) for Treatment of Malignant Ascites
       'NCT04080986', # DOuble SEquential External Defibrillation for Refractory VF
       'NCT04108273', # Brain Plasticity Underlying Acquisition of New Organizational Skills in Children
       'NCT04272489', # Pattern Recognition Prosthetic Control (2020-03-01)
       'NCT04281134', # Development of Adaptive Deep Brain Stimulation for OCD
      ]
    end

    def source_model_name
      Ctgov::Study
    end

    def qs_creator
      QsCreator::Study.new
    end

    def get_id_maps
      lookup_mgr.studies
    end

    def assign_existing_studies_missing_prop(code)
      # method to create a file of single snaks for just one property
      qsc=QsCreator::Study.new
      qsc.set_delimiters
      File.open("public/assign_#{code}.txt", "w+") do |f|
        mgr.ids_for_studies_without_prop(code).each {|hash|
          nct_id = hash.keys.first
          study = qsc.get_for(nct_id)
          if study
            qsc.subject = hash.values.first
            f << qsc.quickstatement_for(code)
          end
        }
      end
    end

    def refresh_prop(code)
      #  This works for P8005 - recruitment status.  Not sure how well it will work for other props.
      # method to create a file of single statements for just one property
      # it doesn't remove the old/existing statement
      # it adds a qualifier to datestamp the date this new property was added to the study
      qsc=QsCreator::Study.new
      qsc.set_delimiters
      File.open("public/refresh_#{code}.txt", "w+") { |f|
        # go grab the data for all studies with this property
        # info includes nct_id, qcode, and subj value (currently assuming it's also a qcode)
        mgr.info_for_studies_with_prop(code).each { |hash|
          nct_id = hash.keys.first
          study = qsc.get_for(nct_id)
          if study
            vals = hash.values.first
            qsc.subject = vals.first
            qsc.object = vals.last
            old_stmt = qsc.quickstatement_with_old_subject(code)
            new_stmt = qsc.quickstatement_with_new_subject(code)
            if old_stmt.strip != new_stmt.strip
              f << "\n-#{old_stmt}"
              f << "#{new_stmt}"
              #f << "#{new_stmt}#{qsc.start_date_qualifier_suffix}"   # includes a date qualifier
            end
          end
        }
      }
    end

  end
end
