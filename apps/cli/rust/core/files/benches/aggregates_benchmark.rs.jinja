//! Performance benchmarks for aggregate computation

use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};
use mytool::internal::aggregates::{CountInfo, compute_count, DerivedStatus, DerivedField};

fn bench_count_computation(c: &mut Criterion) {
    let mut group = c.benchmark_group("count_computation");
    
    for size in [100, 1000, 10000].iter() {
        let items: Vec<i32> = (0..*size).collect();
        
        group.bench_with_input(BenchmarkId::from_parameter(size), size, |b, &size| {
            b.iter(|| {
                compute_count(black_box(&items), black_box(size))
            });
        });
    }
    
    group.finish();
}

fn bench_derived_status_computation(c: &mut Criterion) {
    let mut group = c.benchmark_group("derived_status_computation");
    
    for field_count in [1, 5, 10, 20].iter() {
        group.bench_with_input(BenchmarkId::from_parameter(field_count), field_count, |b, &field_count| {
            b.iter(|| {
                let mut derived = DerivedStatus::new();
                for i in 0..field_count {
                    derived.add_field(
                        format!("field_{}", i),
                        DerivedField::count(format!("Field {}", i), i)
                    );
                }
                black_box(derived)
            });
        });
    }
    
    group.finish();
}

fn bench_count_formatter(c: &mut Criterion) {
    let count = CountInfo::new(30, 847);
    
    c.bench_function("count_formatter_format", |b| {
        b.iter(|| {
            mytool::internal::aggregates::CountFormatter::format(black_box(&count))
        });
    });
    
    c.bench_function("count_formatter_format_with_percentage", |b| {
        b.iter(|| {
            mytool::internal::aggregates::CountFormatter::format_with_percentage(black_box(&count))
        });
    });
    
    c.bench_function("count_formatter_format_compact", |b| {
        b.iter(|| {
            mytool::internal::aggregates::CountFormatter::format_compact(black_box(&count))
        });
    });
}

fn bench_derived_field_formatting(c: &mut Criterion) {
    let count_field = DerivedField::count("Comments", 7);
    let ratio_field = DerivedField::ratio("Tests", 3, 3);
    let status_field = DerivedField::status("State", "active");
    let duration_field = DerivedField::duration("Runtime", 330);
    
    c.bench_function("derived_field_format_count", |b| {
        b.iter(|| black_box(&count_field).format());
    });
    
    c.bench_function("derived_field_format_ratio", |b| {
        b.iter(|| black_box(&ratio_field).format());
    });
    
    c.bench_function("derived_field_format_status", |b| {
        b.iter(|| black_box(&status_field).format());
    });
    
    c.bench_function("derived_field_format_duration", |b| {
        b.iter(|| black_box(&duration_field).format());
    });
}

criterion_group!(
    benches,
    bench_count_computation,
    bench_derived_status_computation,
    bench_count_formatter,
    bench_derived_field_formatting
);
criterion_main!(benches);
