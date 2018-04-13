defmodule Mgp.Sync do
  use Task

  def start_link(_arg) do
    Task.start_link(&sync/0)
  end

  def sync() do
    receive do
    after
      15_000 ->
        rsync()
        sync()
    end
  end

  # Dont optimize lmd, lmt timestamps for master tables like products, customers etc
  defp rsync() do
    fin = get_fin_year()
    case rsync_relevant_dirs(fin) do
      {result, 0} ->
        case Enum.any?(dbf_files(), fn x -> String.contains?(result, x) end) do
          true ->
            import_data(fin)

          false ->
            false
        end

      {_, _} ->
        false
    end
  end

  # check if it is oct, nov, dec if yes sync current fin year and prev year i.e.
  # after dec; sync only current_year - 1 i.e. 2018 - 1
  defp get_fin_year() do
    today = Date.utc_today()
    month = today.month
    case (month == 10 or month == 11 or month == 12) do
      false ->
        %{flag: false, fin_year: today.year-1}
      true ->
        %{flag: true, fin_year: today.year, prev_fin_year: today.year-1}
    end
  end

  defp import_data(%{flag: false, fin_year: fin_year}) do
    Mgp.Sync.ImportData.populate(fin_year)
  end

  defp import_data(%{flag: false, fin_year: fin_year, prev_fin_year: prev_fin_year}) do
    Mgp.Sync.ImportData.populate(prev_fin_year)
    Mgp.Sync.ImportData.populate(fin_year)
  end

  defp dbf_files, do: Mgp.Sync.ImportData.dbf_files_list()

  defp rsync_relevant_dirs(%{flag: false, fin_year: fin_year}) do
    y1 = get_last_2_chars_from_year(fin_year)
    System.cmd("rsync", ["--timeout=45", "-av", "/mnt/scl/MGP#{y1}", "/home/hvaria/backup"])
  end

  defp rsync_relevant_dirs(%{flag: true, fin_year: fin_year, prev_fin_year: prev_fin_year}) do
    y1 = get_last_2_chars_from_year(fin_year)
    y2 = get_last_2_chars_from_year(prev_fin_year)
    System.cmd("rsync", ["--timeout=60", "-av", "/mnt/scl/MGP#{y2}", "/mnt/scl/MGP#{y1}", "/home/hvaria/backup"])
  end

  defp get_last_2_chars_from_year(year) do
    String.slice(to_string(year), 2, 2)
  end
end

