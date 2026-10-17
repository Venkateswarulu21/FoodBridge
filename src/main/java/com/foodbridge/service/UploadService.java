package com.foodbridge.service;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class UploadService {

    private static final Set<String> ALLOWED = Set.of("jpg", "jpeg", "png", "gif", "webp");

    private final Path dir;

    public UploadService(@Value("${app.upload-dir:uploads}") String uploadDir) {
        this.dir = Paths.get(uploadDir).toAbsolutePath().normalize();
    }

    /** Saves an image under a random name and returns the web path ("uploads/xxxx.jpg"). */
    public Optional<String> saveImage(MultipartFile file) throws IOException {
        if (file == null || file.isEmpty()) return Optional.empty();
        String original = file.getOriginalFilename() == null ? "" : file.getOriginalFilename();
        int dot = original.lastIndexOf('.');
        String ext = dot < 0 ? "" : original.substring(dot + 1).toLowerCase(Locale.ROOT);
        String type = file.getContentType() == null ? "" : file.getContentType();
        if (!ALLOWED.contains(ext) || !type.startsWith("image/")) {
            throw new IllegalArgumentException("The photo must be a JPG, PNG, GIF or WebP image.");
        }
        Files.createDirectories(dir);
        String name = UUID.randomUUID() + "." + ext;
        try (InputStream in = file.getInputStream()) {
            Files.copy(in, dir.resolve(name));
        }
        return Optional.of("uploads/" + name);
    }
}
