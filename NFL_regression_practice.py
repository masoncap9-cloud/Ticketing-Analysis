import marimo

__generated_with = "0.19.2"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    return (mo,)


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    #Project Overview
    ##Project Description:
    This project was adapted from my Business Analytics course ST541, which had us learn the basics of R and multiple regression modeling. However, for this project, our team decided to perform the analysis using all three programming languages we learned over the course of the Fall 2025 semester in order to show a basic competency at using all three (SQL, Python, and R). The project goes as follows.
    1. Initial data files loaded onto Marimo notebook as dataframes, and Marimo's native support of SQL is used for initial dataframe joins with a chained CTE.
    2. After initial joins are completed, Python Polars is used for the data cleaning process and variable generation.
    3. The final dataframe created in this Marimo notebook can be exported to R, where final model comparisons are performed, along with regression analyses to find significant predictors of NFL home game attendance.
    - Specifically, we control for team fixed effects and compare models controlling for year fixed effects, year random effects, week fixed effects, and week random effects. In the end, the model with the lowest AIC and BIC scores was found to be the model with team fixed effects and controlling for year random effects. Next, we removed variables showing high levels of multicollinearity and used a backwards elmination process to find the model with the highest AIC and BIC levels after attempting to include all relevant variables that show low levels of multicollinearity.
    """)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ##Part 1: Creating the full dataframe
    1. Using relative paths makes replication easier
    2. Using Marimo native support for SQL to make initial joins across all three datasets
    3. Using core Python functionality to generate additional columns for the games dataframe that cannot be made easily after joins have been made. The reason for this is because the joins through SQL require me to only have home games. Two variables of interest, winning and losing streaks, require information from all games, whether they are home or away games. Due to this, some data cleaning had to be done prior to joins to ensure the winning and losing streaks are accurate.
    """)
    return


@app.cell
def _():
    import os 
    from pathlib import Path
    import polars as pl
    return Path, pl


@app.cell
def _(Path, pl):
    standings_path = Path('standings.csv')
    attendance_path = Path('Attendance.csv')
    games_path = Path('games.csv')

    standings_df = pl.read_csv(standings_path)
    attendance_df = pl.read_csv(attendance_path)
    return attendance_df, games_path, standings_df


@app.cell(hide_code=True)
def _(games_path, pl):
    games_df = pl.read_csv(games_path,                   infer_schema_length=10000).with_columns([
        pl.col('week').cast(pl.Int64, strict=False)]).filter(
        pl.col('week').is_between(1,17))
    #I attempt to create game winning and losing streak variables to track the number of consecutive wins per game. 
    #Sort by date to ensure chronological order
    games_df = games_df.sort(["year", "week", "date", "time"])

    #Creating lists to store streak counts for each game
    win_streak_counts = []
    loss_streak_counts = []

    #Dictionaries to track current streaks for each team
    team_win_streaks = {}
    team_loss_streaks = {}

    #Iterate through each game in chronological order
    for row in games_df.iter_rows(named=True):
        home_team = row['home_team']
        away_team = row['away_team']
        winner = row['winner']

        #Determining if home team won
        home_won = winner == home_team
        away_won = winner == away_team

        #Getting the current streaks
        home_win_streak = team_win_streaks.get(home_team, 0)
        home_loss_streak = team_loss_streaks.get(home_team, 0)
        away_win_streak = team_win_streaks.get(away_team, 0)
        away_loss_streak = team_loss_streaks.get(away_team, 0)

        #Updating streaks based on current game outcome
        if home_won:
            #Home team won - increment win streak, reset loss streak
            team_win_streaks[home_team] = home_win_streak + 1
            team_loss_streaks[home_team] = 0

            #Away team lost - reset win streak, increment loss streak
            team_win_streaks[away_team] = 0
            team_loss_streaks[away_team] = away_loss_streak + 1

            #Recording the win streak AFTER the win (current streak)
            win_streak_counts.append(team_win_streaks[home_team])
            loss_streak_counts.append(0)  # Home team didn't lose

        elif away_won:
            #Away team won - increment win streak, reset loss streak
            team_win_streaks[away_team] = away_win_streak + 1
            team_loss_streaks[away_team] = 0

            #Home team lost - reset win streak, increment loss streak
            team_win_streaks[home_team] = 0
            team_loss_streaks[home_team] = home_loss_streak + 1

            #Record 0 for home team win streak since they lost
            win_streak_counts.append(0)
            loss_streak_counts.append(team_loss_streaks[home_team])

        else:
            #Handle ties - both teams reset both streaks to 0
            team_win_streaks[home_team] = 0
            team_loss_streaks[home_team] = 0
            team_win_streaks[away_team] = 0
            team_loss_streaks[away_team] = 0

            win_streak_counts.append(0)
            loss_streak_counts.append(0)

    #Adding the streak columns back to games_df
    games_df = games_df.with_columns([
        pl.Series(name="home_team_consecutive_wins", values=win_streak_counts),
        pl.Series(name="home_team_consecutive_losses", values=loss_streak_counts)
    ])

    #Showing the results
    games_df.select(["home_team", 'year', 'week', "away_team", "winner", "home_team_consecutive_wins", "home_team_consecutive_losses"])
    return (games_df,)


@app.cell
def _(mo, standings_df):
    _df = mo.sql(
        f"""
        select * from standings_df;
        """
    )
    return


@app.cell
def _(attendance_df, mo):
    _df = mo.sql(
        f"""
        select * from attendance_df;
        """
    )
    return


@app.cell
def _(games_df, mo):
    _df = mo.sql(
        f"""
        SELECT * FROM games_df;
        """
    )
    return


@app.cell
def _(attendance_df, games_df, mo, standings_df):
    full_data_df = mo.sql(
        f"""
        With 
        attendance_standings as ( 
            select 
            	a.*, 
            	s.* 
            from attendance_df a 
            left join standings_df s 
            	on a.full_name = s.full_name 
            	and a.year = s.year), 
        full_dataset as (
            select 
            	ast.*, 
            	g.*, 
            from attendance_standings ast 
            left join games_df g 
            	on ast.team_name = g.home_team_name 
            	and ast.year = g.year
            	and ast.week = g.week
        )
        select * from full_dataset 
        order by full_name, year, week;
        """
    )
    return (full_data_df,)


@app.cell
def _(mo):
    mo.md(r"""
    ##Part 2: Cleaning the created dataframe
    1. Select existing relevant columns for analysis (not selecting duplicate columns amongst dataframes).
    2. Use Python Polars to generate dummy variables, convert variables to correct data formats, and create lag variables. As we are predicting weekly attendance for NFL home games, we have a temporal precedence issue when using statistics collected at the end of the game to predict values collected at the beginning of the game. Lagging weekly variables by one week and yearly variables by one year solves this problem.
    """)
    return


@app.cell(hide_code=True)
def _(full_data_df, pl):
    clean_full_dataframe = full_data_df.select([
                         'home_team', 
                         'away_team', 
                         'year', 
                         'week', 
                         'weekly_attendance', 
                         'winner', 
                         'tie', 
                         'day', 
                         'date', 
                         'time', 
                         'pts_win', 
                         'pts_loss', 
                         'yds_win', 
                         'turnovers_win', 
                         'yds_loss', 
                         'turnovers_loss', 
                         'wins', 
                         'loss', 
                         'points_for', 
                         'points_against', 
                         'points_differential', 
                         'margin_of_victory', 
                         'strength_of_schedule', 
                         'simple_rating', 
                         'offensive_ranking', 
                         'defensive_ranking', 
                         'playoffs_dummy',   
                         'home_team_consecutive_wins', 
                         'home_team_consecutive_losses',
    'sb_winner']).filter(pl.col('home_team').is_not_null()).with_columns(
                            pl.when(pl.col('tie')!= 'NA').then(1).otherwise(0).alias('tie_dummy'), 
                             pl.when(pl.col('day') == 'Sun').then(0)
                             .when(pl.col('day')== 'Mon').then(1)
                             .when(pl.col('day')=='Tue').then(2)
                             .when(pl.col('day')=='Wed').then(3)
                             .when(pl.col('day')=='Thu').then(4)
                             .when(pl.col('day')=='Fri').then(5)
                             .when(pl.col('day')=='Sat').then(6).otherwise(None).alias('day_dummy'), 
    pl.when(pl.col('winner')==pl.col('home_team')).then(1)
        .when(pl.col('winner')==pl.col('away_team')).then(0).otherwise(None).alias('home_win')).sort(['home_team','year', 'week']).with_columns([
        pl.col('weekly_attendance').shift(1).over(['home_team', 'year']).alias('weekly_attendance_lag'),
        pl.col('pts_win').shift(1).over(['home_team', 'year']).alias('pts_win_lag'), 
        pl.col('pts_loss').shift(1).over(['home_team', 'year']).alias('pts_loss_lag'), 
        pl.col('yds_win').shift(1).over(['home_team', 'year']).alias('yds_win_lag'),
        pl.col('turnovers_win').shift(1).over(['home_team', 'year']).alias('turnovers_win_lag'),
        pl.col('yds_loss').shift(1).over(['home_team', 'year']).alias('yds_loss_lag'),
        pl.col('turnovers_loss').shift(1).over(['home_team', 'year']).alias('turnovers_loss_lag'),
        pl.col('tie_dummy').shift(1).over(['home_team', 'year']).alias('tie_dummy_lag'),
        pl.col('day_dummy').shift(1).over(['home_team', 'year']).alias('day_dummy_lag'), 
        pl.col('home_team_consecutive_wins').shift(1).over(['home_team', 'year']).alias('win_streak_lag'), 
        pl.col('home_team_consecutive_losses').shift(1).over(['home_team', 'year']).alias('lose_streak_lag')

                             ]).with_columns([
        pl.col('win_streak_lag').fill_null(0), 
        pl.col('lose_streak_lag').fill_null(0)]).join(
        full_data_df.select(['home_team', 
                             'year', 
                             'wins', 
                             'loss', 
                             'points_for', 
                             'points_against',
                             'points_differential'
                             , 'margin_of_victory',
                             'strength_of_schedule',
                             'simple_rating',
                             'offensive_ranking', 
                             'defensive_ranking',
                             'playoffs_dummy']).unique()
        .with_columns([(pl.col('year') + 1).alias('next_year')])
        .select([
            pl.col('home_team'), 
            pl.col('next_year').alias('year'), 
            pl.col('wins').alias('lag_wins'), 
            pl.col('loss').alias('lag_loss'), 
            pl.col('points_for').alias('lag_points_for'), 
            pl.col('points_against').alias('lag_points_against'), 
            pl.col('points_differential').alias('lag_points_differential'),  pl.col('margin_of_victory').alias('lag_margin_of_victory'), 
            pl.col('strength_of_schedule').alias('lag_strength_of_schedule'), 
            pl.col('simple_rating').alias('lag_simple_rating'), 
            pl.col('offensive_ranking').alias('lag_offensive_ranking'), 
            pl.col('defensive_ranking').alias('lag_defensive_ranking'), 
            pl.col('playoffs_dummy').alias('lag_playoffs_dummy')]), on=['home_team', 'year'], how='left')


    all_data_types = clean_full_dataframe.dtypes
    print(f'All column data types: {all_data_types}')
    clean_full_dataframe
    return (clean_full_dataframe,)


@app.cell(hide_code=True)
def _(clean_full_dataframe):
    final_clean_full_dataframe = clean_full_dataframe.select([
                        'home_team', 
                        'away_team', 
                        'year', 
                        'week', 
                        'weekly_attendance', 
                        'weekly_attendance_lag', 
                        'home_team_consecutive_wins',
                        'win_streak_lag', 
                        'home_team_consecutive_losses',
                        'lose_streak_lag',
                        'pts_win_lag', 
                        'pts_loss_lag', 
                        'yds_win_lag', 
                        'turnovers_win_lag', 
                        'yds_loss_lag', 
                        'turnovers_loss_lag', 
                        'tie_dummy_lag', 
                        'day_dummy_lag', 
                        'lag_wins',
                        'lag_loss',
                        'lag_points_for', 
                        'lag_points_against',
                        'lag_points_differential', 
                        'lag_margin_of_victory', 
                        'lag_strength_of_schedule', 
                        'lag_simple_rating', 
                        'lag_offensive_ranking', 
                        'lag_defensive_ranking', 
                        'lag_playoffs_dummy', 

                          ])
    final_clean_full_dataframe.head(50)
    return (final_clean_full_dataframe,)


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    ##Part 3: Export the final dataframe for model comparison & analysis in RStudio
    ####Now that the data cleaning process is complete, we can now finally analyze the data. We wanted to show basic competency at making model comparisons and running comparisons in R for positions that may require R usage.
    """)
    return


@app.cell
def _(Path, final_clean_full_dataframe):
    output_dir = Path.cwd() / 'final_dataframe'
    output_dir.mkdir(parents=True, exist_ok=True)
    output_file = output_dir / 'attendance_with_lags.csv' 
    final_clean_full_dataframe.write_csv(output_file)
    print(f'- Successfully exported data!')
    print(f'- File Location: {output_file}') 
    print(f'- Rows exported: {final_clean_full_dataframe.shape[0]}')
    print(f'- Columns exported: {final_clean_full_dataframe.shape[1]}')
    return


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
