# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("tibble", "haven", "dplyr"), # Packages that your targets need for their tasks.
  format = "qs" # Optionally set the default storage format. qs is fast.

  # Pipelines that take a long time to run may benefit from
  # optional distributed computing. To use this capability
  # in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs. For example, the following
  # sets a controller that scales up to a maximum of two workers
  # which run as local R processes. Each worker launches when there is work
  # to do and exits if 60 seconds pass with no tasks to run.
  #
  #   controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
  #
  # Alternatively, if you want workers to run on a high-performance computing
  # cluster, select a controller from the {crew.cluster} package.
  # For the cloud, see plugin packages like {crew.aws.batch}.
  # The following example is a controller for Sun Grid Engine (SGE).
  #
  #   controller = crew.cluster::crew_controller_sge(
  #     # Number of workers that the pipeline can scale up to:
  #     workers = 10,
  #     # It is recommended to set an idle time so workers can shut themselves
  #     # down if they are not running tasks.
  #     seconds_idle = 120,
  #     # Many clusters install R as an environment module, and you can load it
  #     # with the script_lines argument. To select a specific verison of R,
  #     # you may need to include a version string, e.g. "module load R/4.3.2".
  #     # Check with your system administrator if you are unsure.
  #     script_lines = "module load R"
  #   )
  #
  # Set other options as needed.
)

tar_source()

# Replace the target list below with your own:
list(
  tar_target(
    silc_2012, {
      p_df <- read_sav("data/silc/2012/SILC 2012_P.sav") %>%
        select_and_rename_personal()
      read_sav("data/silc/2012/SILC 2012_H.sav") %>%
        add_weights(., "data/silc/2012/SILC 2012_D.sav") %>%
        select_and_rename_vars() %>%
        merge_personal_df(., p_df)
    }
  ),

  tar_target(
    silc_2013, {
      p_df <- read_sav("data/silc/2013/SILC 2013_P.sav") %>%
        select_and_rename_personal()

      read_sav("data/silc/2013/SILC 2013_H.sav") %>%
        add_weights(., "data/silc/2013/SILC 2013_D.sav") %>%
        select_and_rename_vars() %>%
        merge_personal_df(., p_df)
    }
  ),

  tar_target(
    silc_2014, {
      p_df <- read_sav("data/silc/2014/SILC 2014_P.sav") %>%
        select_and_rename_personal()

      read_sav("data/silc/2014/SILC 2014_H.sav") %>%
        add_weights(., "data/silc/2014/SILC 2014_D.sav") %>%
        select_and_rename_vars() %>%
        merge_personal_df(., p_df)
    }
  ),

  tar_target(
    silc_2015, {
      p_df <- read_sav("data/silc/2015/SILC 2015_P.sav") %>%
        select_and_rename_personal()

      read_sav("data/silc/2015/SILC 2015_H.sav") %>%
        add_weights(., "data/silc/2015/SILC 2015_D.sav") %>%
        select_and_rename_vars() %>%
        merge_personal_df(., p_df)
    }
  ),

  tar_target(
    silc_2016, {
      p_df <- read_sav("data/silc/2016/SILC 2016_P.sav") %>%
        select_and_rename_personal()

      read_sav("data/silc/2016/SILC 2016_H.sav") %>%
        add_weights(., "data/silc/2016/SILC 2016_D.sav") %>%
        select_and_rename_vars() %>%
        merge_personal_df(., p_df)
    }
  ),

  tar_target(
    silc_2017, {
      p_df <- read_sav("data/silc/2017/SILC 2017_P.sav") %>%
        select_and_rename_personal()

      read_sav("data/silc/2017/SILC 2017_H.sav") %>%
        add_weights(., "data/silc/2017/SILC 2017_D.sav") %>%
        select_and_rename_vars() %>%
        merge_personal_df(., p_df)
    }
  ),

  tar_target(
    silc_2018, {
      p_df <- read_dta("data/silc/2018/SILC 2018_P.dta") %>%
        select_and_rename_personal()

      read_dta("data/silc/2018/SILC 2018_H.dta") %>%
        add_weights(., "data/silc/2018/SILC 2018_D.dta") %>%
        select_and_rename_vars() %>%
        merge_personal_df(., p_df)
    }
  ),

  tar_target(
    silc_2019, {
      p_df <- read_dta("data/silc/2019/SILC 2019_P.dta") %>%
        select_and_rename_personal()

      read_sav("data/silc/2019/SILC 2019_H.sav") %>%
        add_weights(., "data/silc/2019/SILC 2019_D.dta") %>%
        select_and_rename_vars() %>%
        merge_personal_df(., p_df)
    }
  ),

  tar_target(
    silc_2020, {
      p_df <- read_sav("data/silc/2020/SILC 2020_P.sav") %>%
        select_and_rename_personal()

      read_sav("data/silc/2020/SILC 2020_H.sav") %>%
        add_weights(., "data/silc/2020/SILC 2020_D.sav") %>%
        select_and_rename_vars() %>%
        merge_personal_df(., p_df)
    }
  ),

  tar_target(
    silc_2021, {
      p_df <- read_sav("data/silc/2021/SILC 2021_P.sav") %>%
        select_and_rename_personal()

      read_sav("data/silc/2021/SILC 2021_H.sav") %>%
        add_weights(., "data/silc/2021/SILC 2021_D.sav") %>%
        select_and_rename_vars() %>%
        merge_personal_df(., p_df)
    }
  ),

  tar_target(
    silc_2022, {
      p_df <- read_sav("data/silc/2022/SILC 2022_P.sav") %>%
        select_and_rename_personal()

      read_sav("data/silc/2022/SILC 2022_H.sav") %>%
        add_weights(., "data/silc/2022/SILC 2022_D.sav") %>%
        select_and_rename_vars() %>%
        merge_personal_df(., p_df)
    }
  ),

  tar_target(
    silc_variable_availability, {
      bind_rows(
        create_colnames_df(silc_2012, 2012),
        create_colnames_df(silc_2013, 2013),
        create_colnames_df(silc_2014, 2014),
        create_colnames_df(silc_2015, 2015),
        create_colnames_df(silc_2016, 2016),
        create_colnames_df(silc_2017, 2017),
        create_colnames_df(silc_2018, 2018),
        create_colnames_df(silc_2019, 2019),
        create_colnames_df(silc_2020, 2020),
        create_colnames_df(silc_2021, 2021),
        create_colnames_df(silc_2022, 2022)
      )
    }
  )
)
