defmodule Image.Options.Crop do
  @moduledoc """
  Options and option validation for `Image.crop/5`.

  """

  import Image,
    only: [
      is_percent: 1,
      is_positive_percent: 1,
      is_box: 4
    ]

  @typedoc """
  Options applicable to cropping an
  image.

  Currently there are no options.

  """
  @type crop_options :: []

  @typedoc """
  Indicates how to determine where to crop
  an image to fill a target area.

  * `:none` means the image will be reduced
    to fit the required bounding box and
    no cropping will occur.

  * `:center` means crop from the center of
    the image. The central part of the image
    will be returned, cropped to fill the
    bounding box.

  * `:entropy` uses an entropy measure.

  * `:attention` means crop the image by looking
    for features likely to draw human attention.

  * `:low` means position the crop towards the
    low coordinate. This means the bottom part
    of the image remains after the crop.

  * `:high` means position the crop towards the
    high coordinate. This means the top part
    of the image remains after the crop.

  """
  @type crop_focus :: :none | :center | :entropy | :attention | :low | :high

  # The meaning of :low and :high are deliberately
  # Although the verb is crop (to remove) most
  # would expect this verb to describe what remains
  # after cropping. Indeed that is already the behaviour for
  # :center and :attention.

  # Note too that we use US English spelling as apposed
  # to the libvips British English spelling. The
  # assumption being that most developers expect
  # US English.

  @crop_map %{
    none: :VIPS_INTERESTING_NONE,
    center: :VIPS_INTERESTING_CENTRE,
    entropy: :VIPS_INTERESTING_ENTROPY,
    attention: :VIPS_INTERESTING_ATTENTION,
    low: :VIPS_INTERESTING_HIGH,
    high: :VIPS_INTERESTING_LOW
  }

  @crop Map.keys(@crop_map)

  @doc """
  Validates options to `Iamge.crop/5`.

  """
  def validate_options(options) do
    case Enum.reduce_while(options, options, &validate_option(&1, &2)) do
      {:error, value} ->
        {:error, value}

      options ->
        {:ok, options}
    end
  end

  defp validate_option(_other, options) do
    {:cont, options}
  end

  @doc false
  def validate_crop(crop, options) when crop in @crop do
    crop = Map.fetch!(@crop_map, crop)
    {:cont, Keyword.put(options, :crop, crop)}
  end

  def validate_crop(crop, _options) do
    {:halt, {:error, invalid_crop(crop)}}
  end

  @doc false
  def normalize_box({w, _h} = dims, left, top, width, height) when is_percent(left) do
    normalize_box(dims, round(left * w), top, width, height)
  end

  def normalize_box({_w, h} = dims, left, top, width, height) when is_percent(top) do
    normalize_box(dims, left, round(top * h), width, height)
  end

  def normalize_box({w, _h} = dims, left, top, width, height) when is_positive_percent(width) do
    normalize_box(dims, left, top, round(width * w), height)
  end

  def normalize_box({_w, h} = dims, left, top, width, height) when is_positive_percent(height) do
    normalize_box(dims, left, top, width, round(height * h))
  end

  def normalize_box(_dims, left, top, width, height) when is_box(left, top, width, height) do
    {left, top, width, height}
  end

  def normalize_box(_dims, _left, _top, width, _height)
      when not is_integer(width) and not is_positive_percent(width) do
    {:error, size_error("width", width)}
  end

  def normalize_box(_dims, _left, _top, _width, height)
      when not is_integer(height) and not is_positive_percent(height) do
    {:error, size_error("height", height)}
  end

  def normalize_box(_dims, left, _top, _width, _height)
      when not is_integer(left) and not is_positive_percent(left) do
    {:error, location_error("left", left)}
  end

  def normalize_box(_dims, _left, top, _width, _height)
      when not is_integer(top) and not is_positive_percent(top) do
    {:error, location_error("top", top)}
  end

  defp size_error(dim, size) do
    "#{dim} must be a percentage expressed as a float greater than 0.0 and " <>
      "less than or equal to 1.0. Found #{inspect(size)}"
  end

  defp location_error(dim, size) do
    "#{dim} must be a percentage expressed as a float beteen -1.0 and 1.0. " <>
      "Found #{inspect(size)}"
  end

  defp invalid_crop(crop) do
    "Invalid crop option #{inspect(crop)}. Valid values are #{inspect(@crop)}"
  end
end
