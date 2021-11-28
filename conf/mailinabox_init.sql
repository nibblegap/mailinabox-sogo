CREATE TABLE `miab_users` (
  `id` int(11) NOT NULL auto_increment,
  `password` varchar(106) NOT NULL,
  `email` varchar(100) NOT NULL,
  `name` varchar(100) NOT NULL,
  `maildir` varchar(100) NOT NULL,
  `extra` varchar(50),
  `privileges` varchar(20) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `miab_aliases` (
  `id` int(11) NOT NULL auto_increment,
  `source` varchar(100) NOT NULL,
  `destination` varchar(100) NOT NULL,
  `permitted_senders` varchar(100),
  PRIMARY KEY (`id`),
  UNIQUE KEY `source` (`source`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


/* For testing purposes. Probably outdated aswell. */
/*
INSERT INTO `mailinabox`.`miab_users`
  (`id`, `password` , `email`, `name`, maildir, extra, privileges, active)
VALUES
  ('1', 'YjTRjcHIoEXPhYASZRTleLbcH5DCwjDTLgZA87/q4GJ4a1N7', 't1@test.com', 'Test 1', 'test.com/t1/', NULL, 'admin', 1), # password is test
  ('2', 'YjTRjcHIoEXPhYASZRTleLbcH5DCwjDTLgZA87/q4GJ4a1N7', 't2@test.com', 'Test 2', 'test.com/t2/', NULL, 'admin', 1); # password is test


INSERT INTO `mailinabox`.`miab_aliases`
  (`id`, `source`, `destination`)
VALUES
  ('1', 'alias1@test.com', 't1@test.com'),
  ('2', 'alias2@test.com', 't2@test.com'),
  ('3', 'alias3@test.com', 't2@test.com'),
  ('4', 'alias4@test.com', 't2@test.com'),
  ('5', 'alias5@test.com', 't3@test.com');
*/