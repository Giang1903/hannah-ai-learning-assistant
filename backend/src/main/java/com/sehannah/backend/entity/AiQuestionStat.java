package com.sehannah.backend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

/**
 * Thong ke chu de cau hoi sinh vien hoi AI theo tung khoa hoc.
 * Giup giang vien biet sinh vien hay thac mac ve noi dung nao.
 */
@Entity
@Table(name = "ai_question_stats")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AiQuestionStat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @Column(nullable = false, length = 200)
    private String keyword;

    @Column(name = "ask_count", nullable = false)
    @Builder.Default
    private Integer askCount = 1;

    @Column(name = "last_asked", nullable = false)
    private LocalDateTime lastAsked;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (lastAsked == null) {
            lastAsked = LocalDateTime.now();
        }
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
