
///
module simple_matrix;

import core.stdc.stdlib;

import std.traits : Unqual;

///
struct Vector(T)
{
	///
	T* ptr;
	///
	size_t length;
	///
	ptrdiff_t shift;

	///
	mixin _D1!(Vector, T);

	ref inout(T) front() inout @property
	in
	{
		assert(length);
	}
	body
	{
		return ptr[0];
	}

	///
	void popFront()
	in
	{
		assert(length);
	}
	body
	{
		 ptr += shift;
		 length--;
	}

	///
	void popFrontN(size_t n)
	in
	{
		assert(length >= n);
	}
	body
	{
		 ptr += shift * n;
		 length -= n;
	}

	///
	ref inout(T) back() inout @property
	in
	{
		assert(length);
	}
	body
	{
		return ptr[shift * (length - 1)];
	}

	///
	void popBack()
	in
	{
		assert(length);
	}
	body
	{
		 length--;
	}

	///
	void popBackN(size_t n)
	in
	{
		assert(length >= n);
	}
	body
	{
		 length -= n;
	}

	///
	ref inout(T) opIndex(size_t index) inout
	in
	{
		assert(index < length);
	}
	body 
	{
		return ptr[shift*index];
	}

	///
	inout(Vector) opIndex(size_t[2] range) inout
	in
	{
		assert(range[1] <= length);
	}
	body 
	{
		return typeof(return)(ptr + range[0], range[1]-range[0], shift);
	}
}

///
unittest
{
	import std.range;

	alias VectorD = Vector!double;

	static assert(is(ElementType!VectorD == double));
	static assert(hasSwappableElements!VectorD);
	static assert(hasAssignableElements!VectorD);
}

///
unittest
{
	import std.range;

	alias VectorD = Vector!(const double);

	static assert(is(ElementType!VectorD == const double));
	static assert(hasSwappableElements!VectorD == false);
	static assert(hasAssignableElements!VectorD == false);

	static assert(isRandomAccessRange!VectorD);
	static assert(hasMobileElements!VectorD);
	static assert(hasLvalueElements!VectorD);
	static assert(hasLength!VectorD);
	static assert(hasSlicing!VectorD);
}


///
struct Matrix(T)
{
	///
	T* ptr;
	///
	size_t height;
	///
	size_t width;
	///
	ptrdiff_t shift;

	///
	mixin _D2!(Matrix, T);

	inout(T)[] data() inout
	{
		return ptr[0..height * shift];
	}

	///
	inout(T)* ptrEnd() inout
	{
		return ptr + height * shift;
	}

	///
	inout(Vector!T) transversal(size_t index) inout
	in
	{
		assert(index < width);
	}
	body
	{
		return typeof(return)(ptr+index, height, shift);
	}

	///
	inout(Vector!T) frontTransversal() inout
	in
	{
		assert(!empty);
	}
	body
	{
		return typeof(return)(ptr, height, shift);
	}

	///
	inout(TransposedMatrix!T) transposed() inout
	{
		return typeof(return)(this);
	}

	///
	Matrix!(Unqual!T) transpose() const
	{
		import std.traits : Unqual;
		auto m = typeof(return)(width, height);
		size_t i;
		foreach(row; cast(Matrix!(Unqual!T))this)
		{
			foreach(j, e; row)
			{
				m[j, i] = e;
			}
			i++;
		}
		
		return m;
	}

	///
	this(size_t height, size_t width) inout
	{
		this(height, width, width);
	}

	///
	this(inout(T)* ptr, size_t height, size_t width) inout
	{
		this(ptr, height, width, width);
	}

	///
	this(size_t height, size_t width, size_t shift) inout
	{
		this(new inout(T)[height * shift].ptr, height, width, shift);
	}

	///
	this(inout(T)* ptr, size_t height, size_t width, size_t shift) inout
	{
		this.ptr = ptr;
		this.height = height;
		this.width = width;
		this.shift = shift;
	}

	///
	inout(T)[] front() inout @property
	{
		assert(height);
		return ptr[0..width];
	}

	///
	void popFront()
	in
	{ 
		assert(!empty); 
	}
	body 
	{
		ptr += shift;
		height--;
	}

	///
	void popFrontN(size_t n)
	in
	{ 
		assert(height >= n); 
	}
	body 
	{
		ptr += shift*n;
		height -= n;
	}

	///
	inout(T)[] back() inout @property
	{
		assert(height);
		return (ptr+height-1)[0..width];
	}

	///
	void popBack()
	in
	{ 
		assert(!empty); 
	}
	body 
	{
		height--;
	}

	///
	void popBackN(size_t n)
	in
	{ 
		assert(height >= n); 
	}
	body 
	{
		height -= n;
	}


	inout(T)[] opIndex(size_t heightI) inout
	in
	{
		assert(heightI < height);
	}
	body 
	{
		auto l = heightI * shift;
		return ptr[l .. l + width];
	}

	///
	ref inout(T) opIndex(size_t heightI, size_t widthI) inout
	in
	{
		assert(heightI < height);
		assert(widthI < width);		
	}
	body 
	{
		return ptr[heightI * shift + widthI];
	}

	///
	inout(typeof(this)) opIndex(size_t[2] range) inout
	in
	{
		assert(range[1] <= height);
	}
	body 
	{
		return typeof(return)(ptr + shift * range[0], range[1] - range[0], width, shift);
	}

	///
	inout(typeof(this)) opIndex(size_t[2] range0, size_t[2] range1) inout
	in
	{
		assert(range0[1] <= height);
		assert(range1[1] <= width);
	}
	body 
	{
		return typeof(return)(ptr + range1[0] + shift * range0[0], range0[1] - range0[0], range1[1] - range1[0], shift);
	}
}

///
unittest
{
	import std.range;

	alias MatrixD = Matrix!double;

	static assert(is(ElementType!MatrixD == double[]));
	static assert(hasSwappableElements!MatrixD == false);
	static assert(hasAssignableElements!MatrixD == false);
	static assert(hasLvalueElements!MatrixD == false);
}

///
unittest
{
	import std.range, std.traits;
	import std.typetuple;

	foreach(M; TypeTuple!(Matrix!double, Matrix!(const double)))
	{
		static assert(isRandomAccessRange!M);
		static assert(hasMobileElements!M);
		static assert(isDynamicArray!(ElementType!M));
		static assert(hasLength!M);
		static assert(hasSlicing!M);
	}
}


///
struct TransposedMatrix(T)
{
	///
	Matrix!T matrix;

	///
	mixin _D2!(TransposedMatrix, T);

	///
	size_t width() const @property
	{
		return matrix.height;
	}

	///
	size_t height() const @property
	{
		return matrix.width;
	}

	///
	inout(Matrix!T) transposed() inout
	{
		return matrix;
	}
	
	inout(T)[] transversal(size_t index) inout
	{
		return matrix[index];
	}

	///
	inout(T)[] frontTransversal() inout
	{
		return matrix.front;
	}

	///
	inout(Vector!T) front() inout @property
	in
	{
		assert(!empty);
	}
	body
	{
		return matrix.frontTransversal;
	}

	///
	void popFront()
	in
	{ 
		assert(!empty); 
	}
	body 
	{
		matrix.ptr++;
		matrix.width--;
	}

	///
	void popFrontN(size_t n)
	in
	{ 
		assert(length >= n); 
	}
	body 
	{
		matrix.ptr += n;
		matrix.width -= n;
	}

	///
	inout(Vector!T) back() inout @property
	in
	{
		assert(!empty);
	}
	body
	{
		return matrix.transversal(length-1);
	}

	///
	void popBack()
	in
	{ 
		assert(!empty);
	}
	body 
	{
		matrix.width--;
	}

	///
	void popBackN(size_t n)
	in
	{ 
		assert(matrix.width >= n); 
	}
	body 
	{
		matrix.width -= n;
	}

	///
	auto opIndex(size_t heightI) inout
	in
	{
		assert(heightI < height);
	}
	body 
	{
		return matrix.transversal(heightI);
	}

	///
	ref inout(T) opIndex(size_t heightI, size_t widthI) inout
	in
	{
		assert(heightI < height);
		assert(widthI < width);		
	}
	body 
	{
		return matrix[widthI, heightI];
	}

	///
	inout(typeof(this))  opIndex(size_t[2] range) inout
	in
	{
		assert(range[1] <= height);
	}
	body 
	{
		return typeof(return)(inout(Matrix!T)(matrix.ptr + range[0], matrix.height, range[1] - range[0], matrix.shift));
	}

	///
	inout(typeof(this)) opIndex(size_t[2] range0, size_t[2] range1) inout
	in
	{
		assert(range0[1] <= height);
		assert(range1[1] <= width);
	}
	body 
	{
		return typeof(return)(matrix.opIndex(range1, range0));
	}
}


///
unittest
{
	import std.range;

	alias TransposedMatrixD = TransposedMatrix!double;

	static assert(is(ElementType!TransposedMatrixD == Vector!double));
	static assert(hasSwappableElements!TransposedMatrixD == false);
	static assert(hasAssignableElements!TransposedMatrixD == false);
	static assert(hasLvalueElements!TransposedMatrixD == false);
}

///
unittest
{
	import std.range, std.traits;
	import std.typetuple;

	foreach(M; TypeTuple!(TransposedMatrix!double, TransposedMatrix!(const double)))
	{
		static assert(isRandomAccessRange!M);
		static assert(hasMobileElements!M);
		static assert(hasLength!M);
		static assert(hasSlicing!M);
	}
}

///
unittest
{
	auto m = Matrix!double(3, 4);
}


///
private template _D1(alias This, T)
{
	///
	bool empty() const @property
	{
		return length == 0;
	}

	///
	inout(typeof(this)) save() inout @property
	{
		return this;
	}

	///
	inout(typeof(this)) opIndex() inout
	{
		return this;
	}

	///
	size_t opDollar(size_t pos : 0)() const
	{
		return length;
	}

	///
	size_t[2] opSlice(size_t op)(size_t lb, size_t rb) const
	in
	{
		assert(lb <= rb);
	}
	body
	{
		return [lb, rb];
	}
}


///
private template _D2(alias This, T)
{
	///
	mixin _D1!(This, T);

	///
	size_t length() const @property
	{
		return height;
	}

	///
	size_t opDollar(size_t pos : 1)() const
	{
		return width;
	}
}
