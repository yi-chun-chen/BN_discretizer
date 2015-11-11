using Plotly

trace1 = [
  "x" => [1, 2, 3, 4],
  "y" => [10, 15, 13, 17],
  "type" => "scatter"
]
trace2 = [
  "x" => [1, 2, 3, 4],
  "y" => [16, 5, 11, 9],
  "type" => "scatter"
]

response = Plotly.plot([trace1, trace2], ["filename" => "basic-line", "fileopt" => "overwrite"])
plot_url = response["url"]