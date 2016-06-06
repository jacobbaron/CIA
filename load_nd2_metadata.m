function [omeMeta, metadata]=load_nd2_metadata(nd2_file)
    bf_reader=bfGetReader(nd2_file);
    metadata = bf_reader.getSeriesMetadata();
    omeMeta = bf_reader.getMetadataStore();
end