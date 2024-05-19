-- NURSE RANKS TABLE

-- Insert ranks into the rank table
INSERT INTO rank (rank_id, rank_name) VALUES (1, 'Junior Nurse');
INSERT INTO rank (rank_id, rank_name) VALUES (2, 'Senior Nurse');
INSERT INTO rank (rank_id, rank_name) VALUES (3, 'Head Nurse');

-- Establish hierarchy in the rank_rank table
INSERT INTO rank_rank (rank_rank_id, rank_rank_id1) VALUES (1, 2); -- Junior Nurse is below Senior Nurse
INSERT INTO rank_rank (rank_rank_id, rank_rank_id1) VALUES (2, 3); -- Senior Nurse is below Head Nurse


-- DOCTOR SPECIALIZATIONS TABLE

-- Insert specializations into the specialization table
INSERT INTO specialization (spec_id, spec_name) VALUES (1, 'Cardiologist');
INSERT INTO specialization (spec_id, spec_name) VALUES (2, 'Neurologist');
INSERT INTO specialization (spec_id, spec_name) VALUES (3, 'Oncologist');
INSERT INTO specialization (spec_id, spec_name) VALUES (4, 'Pedo Neurologist');
INSERT INTO specialization (spec_id, spec_name) VALUES (5, 'Pediatrician');

-- Establish hierarchy in the specialization_specialization table   
INSERT INTO specialization_specialization (specialization_spec_id, specialization_spec_id1) VALUES (4, 2); -- Pedo-Neurologist is below Neurologist
